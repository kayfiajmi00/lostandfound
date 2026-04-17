<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// --- ডাটাবেস থেকে মেসেজ কাউন্ট করার লজিক ---
$unread_count = 0; // ডিফল্ট ০

if(isset($_SESSION['user_id'])){
    // আপনার ডাটাবেস কানেকশন ফাইলটি এখানে ইনক্লুড করুন
    // include 'db_config.php'; 
    
    // উদাহরণ কুয়েরি:
    // $uid = $_SESSION['user_id'];
    // $sql = "SELECT COUNT(*) as total FROM messages WHERE receiver_id = '$uid' AND is_read = 0";
    // $result = mysqli_query($conn, $sql);
    // $row = mysqli_fetch_assoc($result);
    // $unread_count = $row['total'];
}

/* টেস্ট করার জন্য নিচের লাইনটি ব্যবহার করে দেখতে পারেন:
   $unread_count = 1; (১ দেখাবে)
   $unread_count = 0; (কিছুই দেখাবে না)
*/
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NSU Recovery</title>

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Plus+Jakarta+Sans:wght@300;400;500;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body, p, a, span { font-family: 'Outfit', sans-serif; }
    h1, .logo, .nav-menu a { font-family: 'Plus Jakarta Sans', sans-serif !important; }

    body { background: #0b1220; color: white; }

    .navbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 8%;
        background: #0b1220;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        position: sticky;
        top: 0;
        z-index: 1000;
    }

    .nav-left .logo {
        font-size: 24px;
        font-weight: 800;
        color: #fdb913;
        text-decoration: none;
    }
    .logo span { color: white; }

    .nav-menu { display: flex; align-items: center; gap: 25px; }
    .nav-menu a {
        text-decoration: none;
        color: #cbd5e1;
        font-weight: 500;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: 0.3s;
    }
    .nav-menu a:hover { color: #3b82f6; }

    /* --- Professional Badge UI --- */
    .icon-container {
        position: relative;
        display: inline-flex;
        align-items: center;
    }

    .nav-badge {
        position: absolute;
        top: -7px;
        right: -9px;
        background: #ef4444; /* মডার্ন রেড */
        color: white;
        font-size: 9px;
        font-weight: 800;
        min-width: 15px;
        height: 15px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #0b1220;
        padding: 1px;
        line-height: 1;
    }

    .profile {
        width: 38px; height: 38px;
        border-radius: 50%;
        background: #3b82f6;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 700;
        cursor: pointer;
    }
    </style>
</head>
<body>

<div class="navbar">
    <div class="nav-left">
        <a href="index.php" class="logo">NSU <span>Recovery</span></a>
    </div>

    <div class="nav-menu">
        <a href="index.php"><i class="ri-home-4-line"></i> Home</a>
        <a href="explore.php"><i class="ri-compass-3-line"></i> Explore</a>
        
        <a href="messages.php">
            <span class="icon-container">
                <i class="ri-mail-line"></i>
                <?php if ($unread_count > 0): ?>
                    <span class="nav-badge"><?php echo $unread_count; ?></span>
                <?php endif; ?>
            </span>
            Messages
        </a> 

        <a href="report.php"><i class="ri-add-circle-line"></i> Report Item</a>
        <a href="recover.php"><i class="ri-shield-check-line"></i> Recover</a>
    </div>

    <div class="nav-right">
        <a href="profile.php" style="text-decoration: none;">
            <div class="profile">
                <?php 
                    echo isset($_SESSION['user_name']) ? strtoupper(substr($_SESSION['user_name'], 0, 1)) : "S"; 
                ?>
            </div>
        </a>
    </div>
</div>

</body>
</html>