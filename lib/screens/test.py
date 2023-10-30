import matplotlib.pyplot as plt
import numpy as np

# 초기 조건 설정
g = 9.81  # 중력가속도 (m/s^2)
v0 = 50   # 초기 속도 (m/s)
theta = 45  # 발사각 (degrees)
dt = 0.01  # 시간 간격
rho = 1.2  # 공기 밀도 (kg/m^3)
C = 1.0  # 항력 계수
A = 0.1  # 단면적 (m^2)
m = 3.0  # 물체 질량 (kg)

# 초기 위치 및 속도 계산
theta = theta * (np.pi / 180)  # 각도를 라디안으로 변환
vx = v0 * np.cos(theta)
vy = v0 * np.sin(theta)

# 포물선 운동을 위한 리스트 생성
x_list, y_list = [], []

# 시간 경과에 따른 운동 계산
t = 0
while True:
    v = np.sqrt(vx**2 + vy**2)
    Fx = -0.5 * rho * v**2 * A * C * vx / m  # x방향 항력
    Fy = -m * g - 0.5 * rho * v**2 * A * C * vy / m  # y방향 항력
    ax = Fx / m
    ay = Fy / m

    x = vx * dt
    y = vy * dt

    vx = vx + ax * dt
    vy = vy + (ay + g) * dt

    if y < 0:  # 땅에 닿으면 반복문 종료
        break

    x_list.append(x)
    y_list.append(y)
    t += dt

# 포물선 운동 그래프 그리기
plt.plot(x_list, y_list)
plt.title('Projectile Motion with Air Resistance (v0 = 50 m/s)')
plt.xlabel('Horizontal Distance (m)')
plt.ylabel('Vertical Distance (m)')
plt.show()