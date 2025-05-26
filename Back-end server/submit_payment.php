<?php
header('Content-Type: application/json');
include 'db.php'; // Your database connection file

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["success" => false, "message" => "No data received"]);
    exit;
}

$provider = $data['provider'];
$date = $data['date'];
$time = $data['time'];
$selectedWorks = $data['selectedWorks'];
$extraCleaning = implode(', ', $data['extraCleaning']);
$repeat = $data['repeat'];
$totalAmount = $data['totalAmount'];
$paymentMethod = $data['paymentMethod'];

// You can choose to save each selected work in a separate table as well
$worksJson = json_encode($selectedWorks);

$sql = "INSERT INTO payments (provider_name, date, time, works, extra_cleaning, repeat_type, amount, payment_method)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param(
    "ssssssis",
    $provider['name'],
    $date,
    $time,
    $worksJson,
    $extraCleaning,
    $repeat,
    $totalAmount,
    $paymentMethod
);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Payment recorded successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save payment"]);
}

$stmt->close();
$conn->close();