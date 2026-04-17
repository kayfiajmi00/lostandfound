<?php
include 'db_connect.php';
session_start();

$current_user_id = $_SESSION['user_id'] ?? null;

if (!isset($_GET['id'])) {
    header("Location: explore.php");
    exit();
}

$item_id = mysqli_real_escape_string($conn, $_GET['id']);

// ডাটাবেস থেকে আইটেম এবং ইউজার তথ্য আনা
$query = "SELECT items.*, users.full_name, users.email, users.user_id as owner_id 
          FROM items 
          JOIN users ON items.user_id = users.user_id 
          WHERE items.item_id = '$item_id'";

$result = mysqli_query($conn, $query);
$item = mysqli_fetch_assoc($result);

if (!$item) {
    echo "<h2 style='color:white; text-align:center; margin-top:50px;'>Item not found!</h2>";
    exit();
}

$is_owner = ($current_user_id == $item['owner_id']);
$db_image_path = $item['item_image'];
$final_image_path = (strpos($db_image_path, 'uploads/') === 0) ? $db_image_path : 'uploads/' . $db_image_path;

// ভেরিফিকেশন স্ট্যাটাস চেক
$verify_status = $_GET['verify'] ?? '';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($item['title']) ?> | Details</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --bg-body: #0a0f1c; --card-bg: #111827; --nsu-gold: #fdb913; --text-main: #f8fafc; --secondary-text: #94a3b8; --accent-blue: #3b82f6; --accent-red: #ef4444; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-main); margin: 0; padding: 0; }
        .main-container { max-width: 1100px; margin: 120px auto 50px; padding: 0 20px; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; background: var(--card-bg); border-radius: 24px; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); }
        .image-container { background: #fff; display: flex; align-items: center; justify-content: center; min-height: 500px; }
        .image-container img { width: 100%; height: 100%; object-fit: contain; }
        .content-container { padding: 40px; position: relative; }
        .type-badge { padding: 6px 14px; border-radius: 8px; font-weight: bold; text-transform: uppercase; font-size: 12px; margin-bottom: 20px; display: inline-block; }
        .badge-lost { background: rgba(239, 68, 68, 0.2); color: var(--accent-red); }
        .badge-found { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
        .item-name { font-size: 3rem; margin: 10px 0; color: #fff; font-weight: 800; text-transform: capitalize; }
        .description-box { background: rgba(59, 130, 246, 0.05); padding: 25px; border-radius: 16px; margin-bottom: 30px; border-left: 4px solid var(--accent-blue); }
        .btn { flex: 1; padding: 15px; border-radius: 12px; text-decoration: none; font-weight: bold; text-align: center; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.3s; cursor: pointer; border: none; font-size: 1rem; }
        .btn-edit { background: var(--nsu-gold); color: #000; }
        .btn-delete { background: var(--accent-red); color: #fff; }
        .btn-verify { background: var(--accent-blue); color: #fff; width: 100%; margin-top: 15px; }
        .status-box { background: rgba(255,255,255,0.03); padding: 25px; border-radius: 16px; border: 1px dashed rgba(255,255,255,0.2); margin-top: 20px; }
    </style>
</head>
<body>
    <?php include 'header.php'; ?> 
    <div class="main-container">
        <div class="details-grid">
            <div class="image-container"><img src="<?= $final_image_path ?>" onerror="this.src='uploads/default_item.png';"></div>
            <div class="content-container">
                <span class="type-badge badge-<?= strtolower($item['item_type'] ?? 'lost') ?>"><?= $item['item_type'] ?? 'LOST' ?></span>
                <h1 class="item-name"><?= htmlspecialchars($item['title']) ?></h1>
                
                <div class="description-box">
                    <h4>Description</h4>
                    <p><?= !empty($item['description']) ? nl2br(htmlspecialchars($item['description'])) : "No detailed description provided." ?></p>
                </div>

                <?php if ($is_owner): ?>
                    <div style="display: flex; gap: 15px;">
                        <a href="edit_item.php?id=<?= $item['item_id'] ?>" class="btn btn-edit">Edit Post</a>
                        <a href="delete_handler.php?id=<?= $item['item_id'] ?>" class="btn btn-delete">Delete</a>
                    </div>

                <?php elseif ($verify_status === 'full'): ?>
                    <div class="status-box" style="border-style: solid; border-color: #22c55e; background: rgba(34, 197, 94, 0.05);">
                        <h4 style="color: #22c55e; margin: 0 0 10px;"><i class="ri-checkbox-circle-fill"></i> Full Verification Successful!</h4>
                        <p style="margin-bottom: 15px;"><strong>Owner Email:</strong> <?= htmlspecialchars($item['email']) ?></p>
                        <a href="chat.php?receiver_id=<?= $item['owner_id'] ?>&item_id=<?= $item['item_id'] ?>" class="btn btn-verify">
                            <i class="ri-send-plane-fill"></i> Send Message Now
                        </a>
                    </div>

                <?php elseif ($verify_status === 'partial'): ?>
                    <div class="status-box" style="border-style: solid; border-color: #3b82f6; background: rgba(59, 130, 246, 0.05);">
                        <h4 style="color: #3b82f6; margin: 0 0 10px;"><i class="ri-checkbox-circle-fill"></i> Verification Successful!</h4>
                        <p style="font-size: 0.85rem; color: var(--secondary-text); margin-bottom: 15px;">Email is hidden. You can contact the owner via direct message.</p>
                        <a href="chat.php?receiver_id=<?= $item['owner_id'] ?>&item_id=<?= $item['item_id'] ?>" class="btn btn-verify">
                            <i class="ri-send-plane-fill"></i> Send Message Now
                        </a>
                    </div>

                <?php elseif ($verify_status === 'failed'): ?>
                    <div class="status-box" style="border-color: var(--accent-red); background: rgba(239, 68, 68, 0.05); border-style: solid;">
                        <p style="color: var(--accent-red); margin: 0 0 10px;">Verification failed. Incorrect information.</p>
                        <a href="verify_claim.php?item_id=<?= $item['item_id'] ?>" class="btn btn-verify" style="background: #334155;">Try Again</a>
                    </div>

                <?php else: ?>
                    <div class="status-box">
                        <h4 style="color: var(--nsu-gold); margin: 0 0 10px;">Security Check</h4>
                        <p style="font-size: 0.85rem; color: var(--secondary-text);">Prove ownership to contact the reporter.</p>
                        <a href="verify_claim.php?item_id=<?= $item['item_id'] ?>" class="btn btn-verify">Verify Identity</a>
                    </div>
                <?php endif; ?>

                <div class="reporter-info" style="margin-top: 30px; border-top: 1px solid #1f2937; padding-top: 15px;">
                    Reported by: <span style="color: #fff; font-weight: bold;"><?= htmlspecialchars($item['full_name']) ?></span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>