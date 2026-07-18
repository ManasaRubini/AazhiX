import cv2
from agents.plastic_agent import analyze_plastic

cap = cv2.VideoCapture(0)

while True:

    ret, frame = cap.read()

    if not ret:
        break

    cv2.imwrite("frame.jpg", frame)

    result = analyze_plastic("frame.jpg")

    print(result)

    cv2.imshow("Camera", frame)

    if cv2.waitKey(1) == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()