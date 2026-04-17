<?php
session_start();
include 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_SESSION['user_id'])) {
    $sender_id = intval($_SESSION['user_id']);
    $receiver_id = intval($_POST['receiver_id']);
    $item_id = intval($_POST['item_id']);
    $message = mysqli_real_escape_string($conn, trim($_POST['message']));

    if ($receiver_id > 0 && !empty($message)) {
        // তোমার ডাটাবেজে timestamp অটো জেনারেট হওয়ার কথা, তাই সেটা বাদ দিলাম
        $sql = "INSERT INTO messages (item_id, sender_id, receiver_id, message) 
                VALUES ('$item_id', '$sender_id', '$receiver_id', '$message')";
        
        if (mysqli_query($conn, $sql)) {
            // সাকসেস হলে চ্যাট পেজে ব্যাক করবে
            header("Location: messages.php?receiver_id=$receiver_id&item_id=$item_id");
            exit();
        } else {
            echo "Error: " . mysqli_error($conn);
        }
    }
} else {
    header("Location: explore.php");
}
?>