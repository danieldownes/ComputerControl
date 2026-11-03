// A palette-indexed 640×480 framebuffer. No browser text rasterization is used.
export const DEFAULT_PALETTE = ['#000000','#0000a0','#00a700','#00a7a0','#a00000','#a000a0','#a05700','#a0a7a0','#505050','#5050ff','#50ff50','#50ffff','#ff5050','#ff50ff','#fff850','#fff8ff'];
export class VgaScreen {
  constructor(canvas, legacy) {
    this.canvas = canvas; this.ctx = canvas.getContext('2d', { alpha: false });
    this.font = Uint8Array.from(atob(legacy.font), c => c.charCodeAt(0));
    this.characters = Array.from(legacy.characters);
    this.lookup = new Map(this.characters.map((c, i) => [c, i]));
    this.pixels = new Uint8Array(640 * 480);
    this.image = this.ctx.createImageData(640, 480);
    this.setPalette(DEFAULT_PALETTE);
  }
  setPalette(colors) { this.palette = colors.slice(); this.rgb = colors.map(c => [parseInt(c.slice(1,3),16),parseInt(c.slice(3,5),16),parseInt(c.slice(5,7),16)]); }
  clear(color = 0) { this.pixels.fill(color); }
  point(x, y, color) { x = Math.round(x); y = Math.round(y); if(x>=0&&x<640&&y>=0&&y<480)this.pixels[y*640+x]=color; }
  rect(x1,y1,x2,y2,color,filled = true) {
    if(!filled){this.line(x1,y1,x2,y1,color);this.line(x1,y2,x2,y2,color);this.line(x1,y1,x1,y2,color);this.line(x2,y1,x2,y2,color);return;}
    const left=Math.max(0,Math.round(Math.min(x1,x2))),right=Math.min(639,Math.round(Math.max(x1,x2))),top=Math.max(0,Math.round(Math.min(y1,y2))),bottom=Math.min(479,Math.round(Math.max(y1,y2)));
    for(let y=top;y<=bottom;y++)this.pixels.fill(color,y*640+left,y*640+right+1);
  }
  line(x0,y0,x1,y1,color) {
    x0=Math.round(x0);y0=Math.round(y0);x1=Math.round(x1);y1=Math.round(y1);
    const dx=Math.abs(x1-x0),sx=x0<x1?1:-1,dy=-Math.abs(y1-y0),sy=y0<y1?1:-1;let err=dx+dy;
    while(true){this.point(x0,y0,color);if(x0===x1&&y0===y1)break;const e2=2*err;if(e2>=dy){err+=dy;x0+=sx;}if(e2<=dx){err+=dx;y0+=sy;}}
  }
  circle(cx,cy,r,color) {for(let y=-r;y<=r;y++){const w=Math.round(Math.sqrt(r*r-y*y));this.line(cx-w,cy+y,cx+w,cy+y,color);}}
  triangle(x,y,width,height,color) {for(let row=0;row<=height;row++){const half=(width/2)*(1-Math.abs(row-height/2)/(height/2));this.line(x,y+row,x+half,y+row,color);}}
  glyph(code,x,y,color=7,bg=0,opaque=true) {
    if(opaque)this.rect(x,y,x+7,y+15,bg);
    for(let row=0;row<16;row++){const bits=this.font[code*16+row];for(let col=0;col<8;col++)if(bits&(128>>col))this.point(x+col,y+row,color);}
  }
  text(row,col,text,color=7,bg=0) {
    let x=(col-1)*8;const y=(row-1)*16;
    for(const c of String(text)){if(x>=640)break;const code=this.lookup.get(c)??(c.charCodeAt(0)<32?c.charCodeAt(0):63);this.glyph(code,x,y,color,bg);x+=8;}
  }
  neat(text,sx,sy,color=2,size=2) {
    if(sx===-1)sx=Math.round((640-text.length*8*size)/2);
    for(let n=0;n<text.length;n++){const code=this.lookup.get(text[n])??63;for(let row=0;row<16;row++)for(let col=0;col<8;col++)if(this.font[code*16+row]&(128>>col))this.rect(sx+(n*8+col)*size-size,sy+row*size-size,sx+(n*8+col)*size,sy+row*size,color,false);}
  }
  present() {
    const out=this.image.data;
    for(let i=0;i<this.pixels.length;i++){const rgb=this.rgb[this.pixels[i]];out[i*4]=rgb[0];out[i*4+1]=rgb[1];out[i*4+2]=rgb[2];out[i*4+3]=255;}
    this.ctx.putImageData(this.image,0,0);
  }
}
