"""Import the manifest into an empty Git repository, one dated commit per file.

The script refuses unrelated existing history and checks original bytes and
timestamps before writing. --resume verifies an already imported prefix first.
"""
from pathlib import Path
from datetime import datetime
import hashlib
import json
import os
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'docs/archive-manifest.json').read_text(encoding='utf-8'))
git = os.environ.get('CC_GIT_EXECUTABLE', 'git')

def run(*args, env=None, check=True):
    return subprocess.run([git, *args], cwd=root, env=env, check=check,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if sys.argv[1:] not in [['--apply'], ['--resume']]:
    raise SystemExit('Use --apply for an empty repository, or --resume to verify and continue a matching archival prefix.')
if not (root / '.git').is_dir():
    raise SystemExit('Initialize Git in the project root first.')
has_head = run('rev-parse', '--verify', 'HEAD', check=False).returncode == 0
if has_head and sys.argv[1:] != ['--resume']:
    raise SystemExit('Refusing to append reconstructed imports to an existing history.')
if run('diff', '--cached', '--name-only').stdout.strip():
    raise SystemExit('The Git index must be empty before importing.')

entries = sorted(manifest['files'], key=lambda e: (e['modified_unix_ns'], e['path'].casefold()))
def same_date(value, expected):
    return datetime.fromisoformat(value.replace('Z', '+00:00')) == datetime.fromisoformat(expected)

def verify_commit(commit, entry):
    paths = run('diff-tree', '--no-commit-id', '--name-only', '-r', '--root', '-z', commit).stdout.decode('utf-8').strip('\0').split('\0')
    if paths != [entry['path']]:
        raise SystemExit('Commit does not match the expected one-file import: ' + commit)
    archived = run('show', commit + ':' + entry['path']).stdout
    if hashlib.sha256(archived).hexdigest() != entry['sha256']:
        raise SystemExit('Git content verification failed: ' + entry['path'])
    dates = run('show', '-s', '--format=%aI%n%cI', commit).stdout.decode().splitlines()
    if len(dates) != 2 or not all(same_date(date, entry['modified_utc']) for date in dates):
        raise SystemExit('Git date verification failed: ' + entry['path'])

completed = run('rev-list', '--reverse', 'HEAD').stdout.decode().splitlines() if has_head else []
if len(completed) > len(entries):
    raise SystemExit('Existing history extends beyond the archival manifest.')
for commit, entry in zip(completed, entries):
    verify_commit(commit, entry)
for entry in entries:
    path = root / entry['path']
    if hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
        raise SystemExit('Original content changed: ' + entry['path'])
    if path.stat().st_mtime_ns != entry['modified_unix_ns']:
        raise SystemExit('Original modification time changed: ' + entry['path'])

for entry in entries[len(completed):]:
    path = root / entry['path']
    run('add', '--', entry['path'])
    env = os.environ.copy()
    env['GIT_AUTHOR_DATE'] = entry['modified_utc']
    env['GIT_COMMITTER_DATE'] = entry['modified_utc']
    title = 'Archive ' + entry['path']
    body = ('Reconstructed archival import; the date is the saved filesystem '
            'modification time, not a recovered original Git commit.\n\n'
            'Original-Modified-UTC: ' + entry['modified_utc'] + '\n'
            'Original-SHA256: ' + entry['sha256'])
    run('commit', '-m', title, '-m', body, env=env)
    verify_commit('HEAD', entry)
    if path.suffix.upper() == '.BAS':
        print(entry['modified_utc'], entry['path'])

print('Imported and verified', len(entries), 'original files, one commit per file.')
