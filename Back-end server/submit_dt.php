<?php
// Enable CORS for Flutter to make requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 1. Connect to your MySQL database
$conn = new mysqli("localhost", "root", "", "flutter_db");
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]);
    exit();
}

// 2. Get and decode JSON data from Flutter
$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

// Optional: log incoming data for debugging
// file_put_contents("debug_log.txt", $rawData);

// 3. Validate input
if (
    !isset($data['user_id']) ||
    !isset($data['date']) ||
    !isset($data['time']) ||
    !isset($data['repeat']) ||
    !isset($data['works']) ||
    !isset($data['extra_services'])
) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

// 4. Extract values
$user_id = $conn->real_escape_string($data['user_id']);
$date = $conn->real_escape_string($data['date']);
$time = $conn->real_escape_string($data['time']);
$repeat = $conn->real_escape_string($data['repeat']);
$works = $conn->real_escape_string(json_encode($data['works']));
$extra_services = $conn->real_escape_string(json_encode($data['extra_services']));

// 5. Insert into job_requests table
$sql = "INSERT INTO job_requests (user_id, date, time, repeat_type, works, extra_services) 
        VALUES ('$user_id', '$date', '$time', '$repeat', '$works', '$extra_services')";

$insert_successful = $conn->query($sql);

// 6. Respond to Flutter
if ($insert_successful) {
    echo json_encode([
        "success" => true,
        "message" => "Job request submitted successfully."
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to submit job request.",
        "error" => $conn->error
    ]);
}

$conn->close();
?>
