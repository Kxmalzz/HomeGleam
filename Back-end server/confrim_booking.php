<?php
include 'db.php'; // your DB connection

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Debug log (optional)
    file_put_contents("debug_log.txt", json_encode($_POST) . PHP_EOL, FILE_APPEND);

    $user_id = $_POST['user_id'] ?? '';
    $provider_id = $_POST['provider_id'] ?? '';
    $selected_works = $_POST['selected_works'] ?? '[]';
    $extra_services = $_POST['extra_services'] ?? '[]';
    $booking_date = $_POST['booking_date'] ?? '';
    $booking_time = $_POST['booking_time'] ?? '';

    // Optional: Decode to validate
    $selected_works = json_decode($selected_works, true);
    $extra_services = json_decode($extra_services, true);

    if (!$user_id || !$provider_id || !$booking_date || !$booking_time) {
        echo json_encode(["success" => false, "message" => "Missing fields"]);
        exit;
    }

    $sql = "INSERT INTO confirmed_bookings 
            (user_id, provider_id, selected_works, extra_services, booking_date, booking_time) 
            VALUES (?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
        exit;
    }

    $selected_works_json = json_encode($selected_works);
    $extra_services_json = json_encode($extra_services);

    $stmt->bind_param("ssssss", $user_id, $provider_id, $selected_works_json, $extra_services_json, $booking_date, $booking_time);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Booking confirmed"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>