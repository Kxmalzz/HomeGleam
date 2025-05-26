<?php

$host = "localhost";
$user = "root";
$password = "";
$db = "flutter_db";

$conn = new mysqli($host, $user, $password, $db);

// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents("php://input"), true);

switch ($method) {
    case 'GET':
        $result = $conn->query("SELECT * FROM service_providers");
        $providers = [];

        while ($row = $result->fetch_assoc()) {
            $providers[] = $row;
        }

        echo json_encode($providers);
        break;

    case 'POST':
        $name = $data['name'] ?? '';
        $phone = $data['phone'] ?? '';
        $email = $data['email'] ?? '';
        $rating = floatval($data['rating'] ?? 0);

        $stmt = $conn->prepare("INSERT INTO service_providers (name, phone, email, rating) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssd", $name, $phone, $email, $rating);
        $stmt->execute();

        echo json_encode(["message" => "Provider added successfully"]);
        break;

    case 'PUT':
        $id = intval($data['id'] ?? 0);
        $name = $data['name'] ?? '';
        $phone = $data['phone'] ?? '';
        $email = $data['email'] ?? '';
        $rating = floatval($data['rating'] ?? 0);

        $stmt = $conn->prepare("UPDATE service_providers SET name=?, phone=?, email=?, rating=? WHERE id=?");
        $stmt->bind_param("sssdi", $name, $phone, $email, $rating, $id);
        $stmt->execute();

        echo json_encode(["message" => "Provider updated successfully"]);
        break;

    case 'DELETE':
        $id = intval($data['id'] ?? 0);

        $stmt = $conn->prepare("DELETE FROM service_providers WHERE id=?");
        $stmt->bind_param("i", $id);
        $stmt->execute();

        echo json_encode(["message" => "Provider deleted successfully"]);
        break;

    default:
        echo json_encode(["message" => "Unsupported method"]);
        break;
}

$conn->close();
?>