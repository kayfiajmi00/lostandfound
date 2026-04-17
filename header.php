<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
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
    /* --- Global Font Fix --- */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body, p, a, input, span, label {
        font-family: 'Outfit', sans-serif;
    }

    h1, h2, h3, h4, h5, h6, .logo, .nav-menu a, button, .btn-submit, .sidebar h2 {
        font-family: 'Plus Jakarta Sans', sans-serif !important;
    }

    i[class^="ri-"], i[class*=" ri-"] {
        font-family: 'remixicon' !important;
    }

    body {
        background: #0b1220;
        color: white;
        margin: 0;
    }

    /* NAVBAR */
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
        transition: 0.3s;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .nav-menu a:hover { color: #3b82f6; }

    .profile {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: #3b82f6;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 700;
        cursor: pointer;
        transition: 0.3s;
    }

    .profile:hover {
        transform: scale(1.1);
        background: #2563eb;
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
        <a href="messages.php"><i class="ri-mail-line"></i> Messages</a> 
        <a href="report.php"><i class="ri-add-circle-line"></i> Report Item</a>
        <a href="recover.php"><i class="ri-shield-check-line"></i> Recover</a>
    </div>

    <div class="nav-right">
        <a href="profile.php" style="text-decoration: none;">
            <div class="profile">
                <?php 
                    if(isset($_SESSION['user_name'])) {
                        echo strtoupper(substr($_SESSION['user_name'], 0, 1));
                    } else {
                        echo "S"; 
                    }
                ?>
            </div>
        </a>
    </div>
</div>