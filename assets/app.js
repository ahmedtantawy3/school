// Get the video element
var video = document.createElement("video");
video.autoplay = true;
video.width = 640
video.height = 480
// Get the canvas element
var canvas = document.createElement("canvas");

canvas.width = 640
canvas.height = 480
var context = canvas.getContext("2d");

// Get the container element
var container = document.getElementById("container");

var newItem = document.createElement('div');

container.appendChild(newItem);
// Append the video and canvas elements to the container
container.appendChild(video);
// container.appendChild(canvas);

// Define a function to capture an image from the video and draw it on the canvas
function capture() {
  context.drawImage(video, 0, 0, canvas.width, canvas.height);
}

// Define a function to send the image data back to Flutter and navigate back
function send() {
  // Convert the canvas image to a data URL
  var dataURL = canvas.toDataURL();

  // Call a Flutter function with dart:js
  window.parent.postMessage({ type: "receiveImage", data: dataURL }, "*");

  // Navigate back with dart:js
  // window.parent.postMessage({ type: "pop", data: dataURL }, "*");
}


// Request access to the camera with WebRTC
navigator.mediaDevices.getUserMedia({ video: true })
  .then(function(stream) {
    // Set the video source to the camera stream
    video.srcObject = stream;

    // Add a click event listener to the video element
    video.addEventListener("click", function() {
      // Capture an image from the video
      capture();

      // Send the image data back to Flutter
      send();
    });
  })
  .catch(function(error) {
    // Handle any errors
    console.error(error);
  });

  // Get the button element
var button = document.getElementById("capture_button");
button.textContent = "إلتقاط";

// Append the button element to the container
container.appendChild(button);

// Add a click event listener to the button element
button.addEventListener("click", function() {
  // Capture an image from the video
  capture();

  // Send the image data back to Flutter
  send();
});
