// Stylized SVG map of Metro Manila — abstract roads/blocks/river
function JWMap({ width = 375, height = 700, dark = false, density = 'normal', crowdState = 'mixed', onBeaconClick, selectedId, showRouteLine = false, etas = {} }) {
  const bg = dark ? '#1a1a1a' : '#EFECE5';
  const block = dark ? '#222' : '#F7F5EF';
  const road = dark ? '#3a3a3a' : '#FFFFFF';
  const roadLine = dark ? '#555' : '#D8D4CA';
  const water = dark ? '#0d2630' : '#D8E4E8';
  const labelColor = dark ? '#888' : JW.body;

  // Beacons positioned on roads
  const allBeacons = [
    { id: 'b1', x: 90, y: 180, code: 'EDSA C-Q', eta: '2 min', crowd: 'siksikan' },
    { id: 'b2', x: 230, y: 250, code: 'EDSA C-Q', eta: '6 min', crowd: 'malwag' },
    { id: 'b3', x: 145, y: 380, code: 'Colon-SM', eta: '4 min', crowd: 'katamtaman' },
    { id: 'b4', x: 280, y: 440, code: 'Cubao-Pasay', eta: '9 min', crowd: 'malwag' },
    { id: 'b5', x: 60, y: 470, code: 'Quiapo-Recto', eta: '1 min', crowd: 'siksikan' },
    { id: 'b6', x: 195, y: 130, code: 'EDSA C-Q', eta: '12 min', crowd: 'malwag', stale: true },
    { id: 'b7', x: 320, y: 320, code: 'Ortigas Loop', eta: '7 min', crowd: 'katamtaman' },
  ];

  let beacons = allBeacons;
  if (density === 'sparse') beacons = allBeacons.slice(0, 3);
  if (density === 'dense') beacons = [...allBeacons,
    { id: 'b8', x: 110, y: 280, code: 'EDSA C-Q', eta: '3 min', crowd: 'malwag' },
    { id: 'b9', x: 250, y: 180, code: 'Quiapo-Recto', eta: '5 min', crowd: 'siksikan' },
    { id: 'b10', x: 70, y: 350, code: 'Colon-SM', eta: '8 min', crowd: 'malwag' },
  ];

  if (crowdState === 'allred') beacons = beacons.map(b => ({ ...b, crowd: 'siksikan' }));
  if (crowdState === 'allgreen') beacons = beacons.map(b => ({ ...b, crowd: 'malwag' }));

  // stops along the route
  const stops = showRouteLine ? [
    { x: 75, y: 200 }, { x: 120, y: 230 }, { x: 165, y: 260 },
    { x: 210, y: 290 }, { x: 245, y: 270 }, { x: 290, y: 240 },
  ] : [];

  return (
    <div style={{ position: 'relative', width, height, overflow: 'hidden', background: bg }}>
      <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}
           style={{ position: 'absolute', inset: 0 }}>
        {/* blocks */}
        <rect x="0" y="0" width={width} height={height} fill={bg}/>
        {/* random blocks */}
        {[
          [10,40,140,90],[160,30,90,70],[260,60,100,80],
          [20,160,130,110],[170,160,110,80],[290,160,80,140],
          [30,290,70,150],[120,290,140,100],[280,320,90,120],
          [10,470,130,90],[160,420,80,140],[260,460,110,100],
          [50,580,90,80],[160,580,140,90],[300,580,70,110],
        ].map(([x,y,w,h], i) => (
          <rect key={i} x={x} y={y} width={w} height={h} rx="2" fill={block}
                stroke={dark ? '#2a2a2a' : '#E8E5DC'} strokeWidth="0.5"/>
        ))}
        {/* river (Pasig) */}
        <path d={`M 0 ${height*0.62} Q ${width*0.3} ${height*0.55}, ${width*0.55} ${height*0.6} T ${width} ${height*0.65} L ${width} ${height*0.69} Q ${width*0.7} ${height*0.66}, ${width*0.45} ${height*0.66} T 0 ${height*0.66} Z`}
              fill={water}/>

        {/* main roads */}
        {/* EDSA - vertical */}
        <line x1="155" y1="0" x2="155" y2={height} stroke={road} strokeWidth="14"/>
        <line x1="155" y1="0" x2="155" y2={height} stroke={roadLine} strokeWidth="0.6" strokeDasharray="6 6"/>
        {/* horizontal main */}
        <line x1="0" y1="220" x2={width} y2="220" stroke={road} strokeWidth="11"/>
        <line x1="0" y1="220" x2={width} y2="220" stroke={roadLine} strokeWidth="0.6" strokeDasharray="6 6"/>
        {/* diagonal */}
        <line x1="0" y1="450" x2={width} y2="380" stroke={road} strokeWidth="9"/>
        <line x1="0" y1="450" x2={width} y2="380" stroke={roadLine} strokeWidth="0.6" strokeDasharray="6 6"/>
        {/* secondary roads */}
        <line x1="0" y1="100" x2={width} y2="100" stroke={road} strokeWidth="6"/>
        <line x1="0" y1="540" x2={width} y2="540" stroke={road} strokeWidth="6"/>
        <line x1="60" y1="0" x2="60" y2={height} stroke={road} strokeWidth="5"/>
        <line x1="295" y1="0" x2="295" y2={height} stroke={road} strokeWidth="5"/>

        {/* route polyline (active) */}
        {showRouteLine && (
          <path d="M 30 195 L 80 210 L 140 220 L 200 230 L 260 235 L 330 245"
                stroke={JW.black} strokeWidth="3.5" fill="none" strokeLinecap="round"/>
        )}

        {/* stops */}
        {stops.map((s, i) => (
          <g key={i}>
            <circle cx={s.x} cy={s.y} r="6" fill={JW.white} stroke={JW.black} strokeWidth="2"/>
          </g>
        ))}

        {/* labels */}
        <text x="160" y="50" fontFamily={JW.font} fontSize="9" fill={labelColor} fontWeight="500">EDSA</text>
        <text x="10" y="215" fontFamily={JW.font} fontSize="9" fill={labelColor} fontWeight="500">AURORA BLVD</text>
        <text x="20" y="640" fontFamily={JW.font} fontSize="9" fill={labelColor} opacity="0.7">PASIG RIVER</text>
        <text x="240" y="95" fontFamily={JW.font} fontSize="9" fill={labelColor} fontWeight="500">CUBAO</text>
        <text x="20" y="395" fontFamily={JW.font} fontSize="9" fill={labelColor} fontWeight="500">QUIAPO</text>
      </svg>

      {/* beacons (DOM, for animations + clickability) */}
      {beacons.map(b => (
        <div key={b.id}
             onClick={() => onBeaconClick && onBeaconClick(b)}
             style={{
               position: 'absolute', left: b.x - 22, top: b.y - 22,
               cursor: 'pointer',
               transform: selectedId === b.id ? 'scale(1.15)' : 'scale(1)',
               transition: 'transform 0.15s',
             }}>
          <JWBeacon stale={b.stale} />
          {(etas[b.id] || selectedId === b.id) && (
            <div style={{
              position: 'absolute', top: 46, left: '50%',
              transform: 'translateX(-50%)',
            }}>
              <JWEtaBubble>{b.eta}</JWEtaBubble>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { JWMap });
