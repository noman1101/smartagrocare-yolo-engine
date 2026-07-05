from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
from PIL import Image
import io

app = FastAPI(title="Smart AgroCare YOLO Engine")

# ✅ Allow your React Native app to communicate with this server
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Load the YOLO11 model ONCE at startup to save RAM
print("Loading YOLO11 weights...")
model = YOLO("best.pt") # Make sure your trained best.pt file is in the same folder

@app.post("/detect")
async def detect_leaf(file: UploadFile = File(...)):
    try:
        # 1. Read the uploaded image from the app
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

        # 2. Run YOLO11 Inference
        results = model(image)

        # 3. Extract the Bounding Box coordinates
        detections = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                # Get the coordinates (x_min, y_min, x_max, y_max)
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                confidence = float(box.conf[0])
                
                detections.append({
                    "confidence": round(confidence, 2),
                    "box": [round(x1), round(y1), round(x2), round(y2)]
                })

        return {"status": "success", "detections": detections}

    except Exception as e:
        print(f"❌ Error: {e}")
        return {"status": "error", "message": str(e)}

@app.get("/")
def root():
    return {"message": "✅ Smart AgroCare YOLO Engine is active"}