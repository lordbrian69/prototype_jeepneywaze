// Phone frame wrapper — minimal iOS frame for canvas
function PhoneFrame({ children, label, dark = false, statusDark = false, hideStatusBar = false }) {
  return (
    <div style={{
      width: 375, height: 812, borderRadius: 44, overflow: 'hidden',
      position: 'relative', background: dark ? '#000' : '#fff',
      boxShadow: '0 30px 60px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.12)',
    }}>
      {/* status bar */}
      {!hideStatusBar && (
        <div style={{
          position: 'absolute', top: 0, left: 0, right: 0, height: 47,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '14px 28px 0', zIndex: 100, pointerEvents: 'none',
        }}>
          <span style={{
            fontFamily: '-apple-system, system-ui', fontWeight: 600, fontSize: 15,
            color: statusDark ? '#fff' : '#000',
          }}>9:41</span>
          <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
            <svg width="16" height="11" viewBox="0 0 16 11">
              <rect x="0" y="7" width="3" height="4" rx="0.6" fill={statusDark?'#fff':'#000'}/>
              <rect x="4.5" y="5" width="3" height="6" rx="0.6" fill={statusDark?'#fff':'#000'}/>
              <rect x="9" y="2.5" width="3" height="8.5" rx="0.6" fill={statusDark?'#fff':'#000'}/>
              <rect x="13.5" y="0" width="3" height="11" rx="0.6" fill={statusDark?'#fff':'#000'}/>
            </svg>
            <svg width="24" height="11" viewBox="0 0 24 12">
              <rect x="0.5" y="0.5" width="20" height="11" rx="3" stroke={statusDark?'#fff':'#000'} strokeOpacity="0.4" fill="none"/>
              <rect x="2" y="2" width="17" height="8" rx="1.5" fill={statusDark?'#fff':'#000'}/>
            </svg>
          </div>
        </div>
      )}
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 120, height: 35, borderRadius: 22, background: '#000', zIndex: 90,
      }}/>
      {/* content */}
      <div className="jw" style={{ width: '100%', height: '100%', position: 'relative', overflow: 'hidden' }}>
        {children}
      </div>
      {/* home indicator */}
      <div style={{
        position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)',
        width: 134, height: 5, borderRadius: 999,
        background: dark ? 'rgba(255,255,255,0.5)' : 'rgba(0,0,0,0.3)',
        zIndex: 100,
      }}/>
    </div>
  );
}

window.PhoneFrame = PhoneFrame;
