<?php
include 'db_connect.php';
session_start();

$current_user_id = $_SESSION['user_id'] ?? null;
$receiver_id = $_GET['receiver_id'] ?? null;
// URL থেকে item_id নেওয়া হচ্ছে অথবা ডিফল্ট কোনো ভ্যালু
$item_id = $_GET['item_id'] ?? 0; 

if (!$current_user_id || !$receiver_id) {
    header("Location: messages.php");
    exit();
}

// ইউজারের নাম আনা
$user_res = mysqli_query($conn, "SELECT full_name FROM users WHERE user_id = '$receiver_id'");
$receiver = mysqli_fetch_assoc($user_res);

// বাটন ক্লিক লজিক
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_msg'])) {
    $msg_text = mysqli_real_escape_string($conn, $_POST['message']);
    
    if (!empty($msg_text)) {
        // তোমার টেবিল স্ট্রাকচার অনুযায়ী: id, item_id, sender_id, receiver_id, message
        $insert_sql = "INSERT INTO messages (item_id, sender_id, receiver_id, message) 
                       VALUES ('$item_id', '$current_user_id', '$receiver_id', '$msg_text')";
        
        if(mysqli_query($conn, $insert_sql)) {
            header("Location: chat.php?receiver_id=$receiver_id&item_id=$item_id");
            exit();
        } else {
            echo "Error: " . mysqli_error($conn);
        }
    }
}

// চ্যাট হিস্ট্রি
$chat_sql = "SELECT * FROM messages WHERE 
             (sender_id = '$current_user_id' AND receiver_id = '$receiver_id') OR 
             (sender_id = '$receiver_id' AND receiver_id = '$current_user_id') 
             ORDER BY timestamp ASC";
$chats = mysqli_query($conn, $chat_sql);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Chat | NSU Recovery</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --main-bg: #0f172a; --card-bg: #1e293b; --accent: #3b82f6; }
        body { font-family: 'Inter', sans-serif; background: var(--main-bg); color: white; margin: 0; }
        .wrapper { max-width: 700px; margin: 50px auto; background: var(--card-bg); height: 85vh; border-radius: 20px; display: flex; flex-direction: column; overflow: hidden; border: 1px solid rgba(255,255,255,0.1); }
        .header { padding: 20px; background: #1e293b; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 15px; }
        .chat-area { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; background: #0f172a; }
        .msg { max-width: 70%; padding: 12px 16px; border-radius: 18px; font-size: 0.95rem; line-height: 1.4; }
        .sent { align-self: flex-end; background: var(--accent); color: white; border-bottom-right-radius: 4px; }
        .received { align-self: flex-start; background: #334155; border-bottom-left-radius: 4px; }
        .footer { padding: 15px; background: #1e293b; border-top: 1px solid rgba(255,255,255,0.1); }
        .input-wrap { display: flex; background: #0f172a; border-radius: 30px; padding: 5px 10px; align-items: center; border: 1px solid #334155; }
        .input-wrap:focus-within { border-color: var(--accent); }
        input { flex: 1; background: transparent; border: none; padding: 12px; color: white; outline: none; }
        .send-btn { background: var(--accent); border: none; width: 42px; height: 42px; border-radius: 50%; color: white; cursor: pointer; transition: 0.3s; }
        .send-btn:hover { transform: scale(1.1); background: #2563eb; }
    </style>
</head>
<body>
    <?php include 'header.php'; ?>
    <div class="wrapper">
        <div class="header">
            <a href="messages.php" style="color: #94a3b8;"><i class="fas fa-arrow-left"></i></a>
            <h3 style="margin: 0; font-size: 1.1rem;"><?= htmlspecialchars($receiver['full_name'] ?? 'Chat') ?></h3>
        </div>
        <div class="chat-area" id="chat">
            <?php while($row = mysqli_fetch_assoc($chats)): ?>
                <div class="msg <?= $row['sender_id'] == $current_user_id ? 'sent' : 'received' ?>">
                    <?= htmlspecialchars($row['message']) ?>
                    <small style="display: block; font-size: 0.65rem; opacity: 0.6; margin-top: 5px; text-align: right;">
                        <?= date('h:i A', strtotime($row['timestamp'])) ?>
                    </small>
                </div>
            <?php endwhile; ?>
        </div>
        <form class="footer" method="POST">
            <div class="input-wrap">
                <input type="text" name="message" placeholder="Type a message..." required autocomplete="off">
                <button type="submit" name="send_msg" class="send-btn">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
        </form>
    </div>
    <script>
        const c = document.getElementById("chat");
        c.scrollTop = c.scrollHeight;
    </script>
</body>
</html>