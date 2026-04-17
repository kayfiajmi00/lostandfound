<?php
include 'db_connect.php';
session_start();

$current_user_id = $_SESSION['user_id'] ?? null;

if (!$current_user_id) {
    header("Location: login.php");
    exit();
}

/**
 * লজিক: তোমাকে যারা মেসেজ পাঠিয়েছে বা যাদের তুমি পাঠিয়েছ, 
 * তাদের একটা ইউনিক লিস্ট তৈরি করা।
 */
$query = "SELECT DISTINCT 
            CASE 
                WHEN sender_id = '$current_user_id' THEN receiver_id 
                ELSE sender_id 
            END AS contact_id,
            users.full_name
          FROM messages 
          JOIN users ON users.user_id = (CASE WHEN sender_id = '$current_user_id' THEN receiver_id ELSE sender_id END)
          WHERE sender_id = '$current_user_id' OR receiver_id = '$current_user_id'
          ORDER BY messages.timestamp DESC";

$result = mysqli_query($conn, $query);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Messages | NSU Recovery</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #0a0f1c; color: white; margin: 0; }
        .inbox-wrapper { max-width: 800px; margin: 120px auto; padding: 0 20px; }
        .inbox-card { background: #111827; border-radius: 20px; border: 1px solid #1f2937; overflow: hidden; }
        .inbox-header { padding: 25px; border-bottom: 1px solid #1f2937; background: rgba(255,255,255,0.02); }
        .chat-item { 
            display: flex; align-items: center; justify-content: space-between;
            padding: 20px 25px; border-bottom: 1px solid #1f2937;
            text-decoration: none; color: white; transition: 0.3s;
        }
        .chat-item:hover { background: rgba(59, 130, 246, 0.05); }
        .user-avatar { 
            width: 50px; height: 50px; background: #3b82f6; 
            border-radius: 50%; display: flex; align-items: center; 
            justify-content: center; font-size: 1.2rem; font-weight: bold;
        }
        .user-info h4 { margin: 0; font-size: 1.1rem; }
        .user-info p { margin: 5px 0 0; color: #94a3b8; font-size: 0.85rem; }
    </style>
</head>
<body>
    <?php include 'header.php'; ?>

    <div class="inbox-wrapper">
        <div class="inbox-card">
            <div class="inbox-header">
                <h2 style="margin:0;"><i class="fas fa-comments" style="color: #3b82f6;"></i> Messages</h2>
            </div>

            <?php if (mysqli_num_rows($result) > 0): ?>
                <?php while($row = mysqli_fetch_assoc($result)): ?>
                    <a href="chat.php?receiver_id=<?= $row['contact_id'] ?>" class="chat-item">
                        <div style="display: flex; align-items: center; gap: 20px;">
                            <div class="user-avatar">
                                <?= strtoupper(substr($row['full_name'], 0, 1)) ?>
                            </div>
                            <div class="user-info">
                                <h4><?= htmlspecialchars($row['full_name']) ?></h4>
                                <p>Click to view conversation</p>
                            </div>
                        </div>
                        <i class="fas fa-chevron-right" style="color: #4b5563;"></i>
                    </a>
                <?php endwhile; ?>
            <?php else: ?>
                <div style="padding: 50px; text-align: center; color: #94a3b8;">
                    <i class="fas fa-envelope-open" style="font-size: 3rem; margin-bottom: 20px; opacity: 0.3;"></i>
                    <p>No messages yet. Start exploring to contact owners!</p>
                </div>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>