<?php
session_start();
include 'db_connect.php';

// ১. চেক করা ইউজার লগইন করা কি না
if (!isset($_SESSION['user_id'])) {
    die("Error: Please login first.");
}

$id_to_delete = isset($_GET['id']) ? intval($_GET['id']) : 0;
$current_user = $_SESSION['user_id'];

// অ্যাডমিন চেক (আপনার সেশনের ভেরিয়েবল অনুযায়ী মিলিয়ে নিন)
$is_admin = (isset($_SESSION['role']) && $_SESSION['role'] === 'admin') || (isset($_SESSION['user_type']) && $_SESSION['user_type'] === 'admin');

if ($id_to_delete === 0) {
    die("Error: Invalid ID.");
}

// ২. ডাটাবেস থেকে ইমেজ পাথ এবং ওনার আইডি চেক করা
$getPathSql = "SELECT item_image, user_id FROM items WHERE item_id = $id_to_delete";
$result = mysqli_query($conn, $getPathSql);

if ($row = mysqli_fetch_assoc($result)) {
    $filePath = $row['item_image'];
    $item_owner = $row['user_id'];

    // ৩. পারমিশন: যদি ইউজার ওনার হয় অথবা অ্যাডমিন হয়
    if ($current_user == $item_owner || $is_admin) {
        
        // ফরেন কি ইস্যু এড়াতে আগে রিলেটেড ডাটা ডিলিট করা (যদি থাকে)
        mysqli_query($conn, "DELETE FROM messages WHERE item_id = $id_to_delete");
        mysqli_query($conn, "DELETE FROM item_claims WHERE item_id = $id_to_delete");

        // ৪. মেইন আইটেম ডিলিট
        $sql = "DELETE FROM items WHERE item_id = $id_to_delete";

        if (mysqli_query($conn, $sql)) {
            // ৫. ফাইল ডিলিট (unlink)
            if (!empty($filePath) && file_exists($filePath)) {
                unlink($filePath); 
            }
            
            // অ্যাডমিন হলে অ্যাডমিন ড্যাশবোর্ডে পাঠাবে
            $redirect = $is_admin ? "admin_dashboard.php" : "index.php";
            header("Location: $redirect?msg=deleted");
            exit;
        } else {
            die("Database Error: " . mysqli_error($conn));
        }
    } else {
        die("Error: Permission denied.");
    }
} else {
    die("Error: Item not found.");
}
?>