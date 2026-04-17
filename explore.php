<?php 
include 'db_connect.php';
include 'header.php'; 

$cat_id = isset($_GET['cat_id']) ? $_GET['cat_id'] : null;
$type = isset($_GET['type']) ? $_GET['type'] : 'all';
?>

<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Plus+Jakarta+Sans:wght@300;400;500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
/* 1. Global Reset & Font Application */
* { 
    margin: 0; 
    padding: 0; 
    box-sizing: border-box; 
}

body { 
    background: #0b1220; 
    font-family: 'Outfit', sans-serif; 
    color: white; 
}

h1, h2, h3, .filter-btn {
    font-family: 'Plus Jakarta Sans', sans-serif; 
}

header { 
    border: none !important; 
    box-shadow: none !important; 
    background: #0b1220;
}

.explore-body { 
    padding: 20px 5% 40px; 
    background: #0b1220;
    min-height: 100vh;
}

.explore-container { 
    display: flex; 
    gap: 25px; 
    align-items: flex-start; 
}

.sidebar {
    flex: 0 0 240px; 
    background: rgba(255, 255, 255, 0.03);
    padding: 20px;
    border-radius: 18px;
    border: 1px solid rgba(255, 255, 255, 0.08);
}

.sidebar h2 { 
    color: #fdb913; 
    margin-bottom: 20px; 
    font-size: 1rem; 
    font-weight: 700;
    text-transform: uppercase;
}

.sidebar ul { 
    list-style: none !important; 
    padding: 0 !important; 
    margin: 0 !important;
}

.sidebar ul li { 
    list-style: none !important; 
    margin-bottom: 6px; 
}

.sidebar ul li a {
    color: #cbd5e1;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 15px;
    border-radius: 12px;
    transition: 0.3s;
    font-size: 0.9rem;
    font-weight: 400;
}

.sidebar ul li a:hover, .sidebar ul li a.active {
    background: #3b82f6;
    color: white;
    font-weight: 600;
}

.main-content { flex: 1; }

.hub-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    margin-bottom: 25px; 
}

.hub-header h1 { 
    color: #fdb913; 
    font-size: 1.8rem; 
    font-weight: 800;
}

.filter-tabs { 
    background: rgba(255, 255, 255, 0.05); 
    padding: 5px; 
    border-radius: 12px; 
    display: flex;
}

.filter-btn {
    padding: 8px 20px;
    color: #94a3b8;
    text-decoration: none;
    border-radius: 10px;
    font-size: 0.85rem;
    font-weight: 700;
}

.filter-btn.active { 
    background: #3b82f6; 
    color: white; 
}

.item-grid { 
    display: grid; 
    grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); 
    gap: 18px; 
}

.item-card { 
    background: #161e2d; 
    border-radius: 18px; 
    overflow: hidden; 
    border: 1px solid rgba(255, 255, 255, 0.06); 
    transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.item-card:hover {
    transform: translateY(-5px);
    border-color: rgba(59, 130, 246, 0.4);
}

.card-img-container { 
    position: relative; 
    height: 150px; 
    background: #1e293b; 
}

.card-img-container img { 
    width: 100%; 
    height: 100%; 
    object-fit: cover; 
}

.status-badge { 
    position: absolute; 
    top: 10px; 
    left: 10px; 
    padding: 4px 12px; 
    border-radius: 6px; 
    font-size: 9px; 
    font-weight: 800; 
    text-transform: uppercase;
    z-index: 10;
}

.status-lost { background: #ef4444; color: white; }
.status-found { background: #10b981; color: white; }

.card-info { padding: 18px; }
.card-info h3 { 
    font-size: 1rem; 
    margin-bottom: 6px; 
    font-weight: 700; 
    white-space: nowrap; 
    overflow: hidden; 
    text-overflow: ellipsis; 
}
.location { font-size: 0.8rem; color: #94a3b8; margin-bottom: 12px; }

.view-btn { 
    display: block; 
    text-align: center; 
    background: rgba(59, 130, 246, 0.1); 
    color: #3b82f6; 
    padding: 10px; 
    border-radius: 10px; 
    text-decoration: none; 
    font-weight: 700; 
    font-size: 0.85rem;
}

.view-btn:hover {
    background: #3b82f6;
    color: white;
}
</style>

<div class="explore-body">
    <div class="explore-container">
        <aside class="sidebar">
            <h2>Categories</h2>
            <ul>
                <li><a href="explore.php" class="<?= !$cat_id ? 'active' : '' ?>"><i class="fa-solid fa-folder-open"></i> View All</a></li>
                <li><a href="explore.php?cat_id=1" class="<?= $cat_id == 1 ? 'active' : '' ?>"><i class="fa-solid fa-laptop"></i> Electronics</a></li>
                <li><a href="explore.php?cat_id=2" class="<?= $cat_id == 2 ? 'active' : '' ?>"><i class="fa-solid fa-file-lines"></i> Documents</a></li>
                <li><a href="explore.php?cat_id=3" class="<?= $cat_id == 3 ? 'active' : '' ?>"><i class="fa-solid fa-wallet"></i> Wallets</a></li>
                <li><a href="explore.php?cat_id=4" class="<?= $cat_id == 4 ? 'active' : '' ?>"><i class="fa-solid fa-pen-nib"></i> Stationery</a></li>
                <li><a href="explore.php?cat_id=5" class="<?= $cat_id == 5 ? 'active' : '' ?>"><i class="fa-solid fa-money-bill-1"></i> Cash</a></li>
                <li><a href="explore.php?cat_id=6" class="<?= $cat_id == 6 ? 'active' : '' ?>"><i class="fa-solid fa-box"></i> Accessories</a></li>
            </ul>
        </aside>

        <main class="main-content">
            <header class="hub-header">
                <h1>Discovery Hub</h1>
                <div class="filter-tabs">
                    <a href="explore.php?cat_id=<?= $cat_id ?>&type=all" class="filter-btn <?= $type == 'all' ? 'active' : '' ?>">All</a>
                    <a href="explore.php?cat_id=<?= $cat_id ?>&type=lost" class="filter-btn <?= $type == 'lost' ? 'active' : '' ?>">Lost</a>
                    <a href="explore.php?cat_id=<?= $cat_id ?>&type=found" class="filter-btn <?= $type == 'found' ? 'active' : '' ?>">Found</a>
                </div>
            </header>

            <div class="item-grid">
                <?php 
                $query = "SELECT * FROM items WHERE 1=1";
                if($cat_id) $query .= " AND category_id = " . intval($cat_id);
                if($type != 'all') $query .= " AND item_type = '" . mysqli_real_escape_string($conn, $type) . "'";
                $query .= " ORDER BY created_at DESC";
                
                $result = mysqli_query($conn, $query);
                
                if(mysqli_num_rows($result) > 0):
                    while($row = mysqli_fetch_assoc($result)): ?>
                        <div class="item-card">
                            <div class="card-img-container">
                                <span class="status-badge status-<?= strtolower($row['item_type']) ?>">
                                    <?= strtoupper($row['item_type']) ?>
                                </span>
                                <?php 
                                    $img_from_db = $row['item_image'];
                                    
                                    // ১. ডাটাবেসে ছবি খালি থাকলে ডিফল্ট ছবি সেট করা
                                    if (empty($img_from_db)) {
                                        $image_path = 'img/default.jpg'; 
                                    } else {
                                        // ২. পাথে uploads/ থাকলে সরাসরি বসা, না থাকলে যোগ করা
                                        $image_path = (strpos($img_from_db, 'uploads/') === 0) ? $img_from_db : 'uploads/' . $img_from_db;
                                    }
                                ?>
                                <img src="<?= htmlspecialchars($image_path) ?>" 
                                     onerror="this.onerror=null; this.src='img/default.jpg';">
                            </div>
                            <div class="card-info">
                                <h3><?= htmlspecialchars($row['title']) ?></h3>
                                <div class="location"><i class="fa-solid fa-location-dot"></i> <?= htmlspecialchars($row['location_name']) ?></div>
                                <a href="details.php?id=<?= $row['item_id'] ?>" class="view-btn">View Details</a>
                            </div>
                        </div>
                    <?php endwhile; 
                else: ?>
                    <div style="grid-column: 1/-1; text-align: center; color: #94a3b8; padding-top: 50px;">
                        <i class="fa-solid fa-magnifying-glass" style="font-size: 2rem; margin-bottom: 10px;"></i>
                        <p>No items found in this category.</p>
                    </div>
                <?php endif; ?>
            </div>
        </main>
    </div>
</div>

<?php include 'footer.php'; ?>