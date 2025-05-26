<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$host = "localhost";
$user = "root";
$password = "";
$db = "flutter_db";

$conn = new mysqli($host, $user, $password, $db);
if ($conn->connect_error) die(json_encode(["error" => "DB connection failed"]));

$result = $conn->query("SELECT * FROM service_providers");
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
?>