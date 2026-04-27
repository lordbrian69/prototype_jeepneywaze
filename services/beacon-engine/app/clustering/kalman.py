"""
Kalman Filter for GPS position smoothing.
Reduces GPS jitter and interpolates positions between ping intervals.
"""
import numpy as np
from filterpy.kalman import KalmanFilter


class KalmanTracker:
    """
    2D Kalman filter tracking (lat, lng) with constant-velocity model.
    State vector: [lat, lng, v_lat, v_lng]
    """

    def __init__(self, lat: float, lng: float):
        kf = KalmanFilter(dim_x=4, dim_z=2)

        # State transition: constant velocity
        dt = 1.0  # 1 second (5-second ping interval, interpolate)
        kf.F = np.array([
            [1, 0, dt, 0],
            [0, 1,  0, dt],
            [0, 0,  1,  0],
            [0, 0,  0,  1],
        ])

        # Measurement function: observe (lat, lng) only
        kf.H = np.array([
            [1, 0, 0, 0],
            [0, 1, 0, 0],
        ])

        # Measurement noise (GPS accuracy ~30m ≈ 0.00027 deg)
        kf.R = np.eye(2) * 0.0001

        # Process noise (vehicle acceleration)
        from filterpy.common import Q_discrete_white_noise
        q = Q_discrete_white_noise(dim=2, dt=dt, var=0.0001)
        kf.Q = np.block([[q, np.zeros((2, 2))], [np.zeros((2, 2)), q]])

        kf.x = np.array([[lat], [lng], [0.0], [0.0]])
        kf.P = np.eye(4) * 0.01

        self.kf = kf

    def update(self, lat: float, lng: float) -> tuple[float, float]:
        """Update with a new GPS measurement, return smoothed position."""
        self.kf.predict()
        self.kf.update(np.array([[lat], [lng]]))
        return float(self.kf.x[0]), float(self.kf.x[1])

    def predict(self) -> tuple[float, float]:
        """Predict next position without a measurement (for interpolation)."""
        self.kf.predict()
        return float(self.kf.x[0]), float(self.kf.x[1])
