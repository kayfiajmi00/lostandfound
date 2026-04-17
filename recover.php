<?php 
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
include 'db_connect.php'; 
include 'header.php'; 

// রিকভারড আইটেম কাউন্ট
$count_query = "SELECT COUNT(*) as total FROM items WHERE status = 'recovered'";
$count_res = mysqli_query($conn, $count_query);
$count_row = mysqli_fetch_assoc($count_res);
$total_recovered = $count_row['total'];
?>

<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Plus+Jakarta+Sans:wght@300;400;500;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
body { background: #0b1220; font-family: 'Outfit', sans-serif; color: white; margin: 0; }

.recover-wrapper { padding: 60px 5% 80px; text-align: center; }

/* টাইটেল স্টাইল */
.gallery-title { 
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 3rem; 
    font-weight: 800; 
    margin-bottom: 10px;
    letter-spacing: -1.5px;
    background: linear-gradient(135deg, #ffffff 50%, #3b82f6 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    display: inline-block;
}

.gallery-subtitle { color: #94a3b8; font-size: 1rem; margin-bottom: 30px; font-family: 'Plus Jakarta Sans', sans-serif; }

.stats-pill {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: rgba(16, 185, 129, 0.08);
    border: 1px solid rgba(16, 185, 129, 0.2);
    color: #10b981;
    padding: 8px 20px;
    border-radius: 100px;
    font-weight: 700;
    font-size: 0.9rem;
    margin-bottom: 50px;
}

/* গ্রিড কন্ট্রোল */
.item-grid { 
    display: grid; 
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); 
    gap: 25px; 
    max-width: 1100px; 
    margin: 0 auto; 
}

/* কার্ড ও ছবির সাইজ ছোট করা হয়েছে */
.item-card { 
    background: #161e2d; 
    border-radius: 24px; 
    border: 1px solid rgba(255, 255, 255, 0.05); 
    overflow: hidden; 
    transition: 0.3s ease;
}

.item-card:hover { transform: translateY(-8px); border-color: rgba(59, 130, 246, 0.3); }

/* ছবির উচ্চতা কমিয়ে ১৮০পিএক্স করা হয়েছে */
.card-img { position: relative; height: 180px; background: #1e293b; }
.card-img img { width: 100%; height: 100%; object-fit: cover; }

.recovered-badge { 
    position: absolute; top: 12px; right: 12px; 
    background: #10b981; color: white; 
    padding: 4px 10px; border-radius: 8px; 
    font-size: 9px; font-weight: 800; 
}

.card-body { padding: 20px; text-align: left; }

.card-body h3 { 
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 1.2rem; 
    color: #f8fafc; 
    margin-bottom: 15px;
}

/* টাইটেল হাইলাইট */
.card-body h3::first-letter { color: #3b82f6; font-size: 1.5rem; font-weight: 800; }

.reporter-box {
    border-top: 1px solid rgba(255, 255, 255, 0.06);
    padding-top: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #64748b;
    font-size: 0.8rem;
}

.reporter-box i { color: #3b82f6; }
.reporter-box span { color: #cbd5e1; font-weight: 600; }
</style>

<main class="recover-wrapper">
    <h1 class="gallery-title">Handover Success Gallery</h1>
    <p class="gallery-subtitle">Celebrating items returned with trust.</p>
    
    <div class="stats-pill">
        <i class="fa-solid fa-check-circle"></i>
        Recovered: <?= $total_recovered ?> Items
    </div>

    <div class="item-grid">
        <?php 
        $sql = "SELECT items.*, users.full_name FROM items 
                LEFT JOIN users ON items.user_id = users.user_id 
                WHERE items.status = 'recovered' ORDER BY items.item_id DESC";
        $result = mysqli_query($conn, $sql);

        while($row = mysqli_fetch_assoc($result)): 
            $img = $row['item_image'];
            $path = (strpos($img, 'uploads/') === 0) ? $img : 'uploads/' . $img;
        ?>
            <div class="item-card">
                <div class="card-img">
                    <span class="recovered-badge">RECOVERED</span>
                    <img src="<?= htmlspecialchars($path) ?>" onerror="this.src='img/default.jpg';">
                </div>
                <div class="card-body">
                    <h3><?= htmlspecialchars($row['title']) ?></h3>
                    <div class="reporter-box">
                        <i class="fa-solid fa-user-shield"></i>
                        By: <span><?= htmlspecialchars($row['full_name'] ?: 'User') ?></span>
                    </div>
                </div>
            </div>
        <?php endwhile; ?>
    </div>
</main>

<?php include 'footer.php'; ?>