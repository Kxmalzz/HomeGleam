<?php

// Enable CORS for local development
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database credentials
$host = "localhost";
$username = "root";
$password = "";
$dbname = "flutter_db"; // Make sure this database exists

// Connect to MySQL
$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]);
    exit();
}

// Read and decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!$data || !isset($data['user_id']) || !isset($data['works']) || !is_array($data['works'])) {
    echo json_encode(["success" => false, "message" => "Invalid or missing data."]);
    exit();
}

$userId = $data['user_id'];
$works = $data['works'];

// Prepare SQL statement
$stmt = $conn->prepare("INSERT INTO work_selections (user_id, work_name, count) VALUES (?, ?, ?)");
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Statement preparation failed: " . $conn->error]);
    exit();
}

// Insert each work selection
foreach ($works as $work) {
    if (!isset($work['name'])) continue;

    $name = $work['name'];
    $count = isset($work['count']) ? intval($work['count']) : 1;

    $stmt->bind_param("ssi", $userId, $name, $count);

    if (!$stmt->execute()) {
        echo json_encode(["success" => false, "message" => "Error inserting $name: " . $stmt->error]);
        $stmt->close();
        $conn->close();
        exit();
    }
}

// Success response
echo json_encode(["success" => true, "message" => "Works saved successfully."]);

$stmt->close();
$conn->close();

?>