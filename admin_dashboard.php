<?php 
include 'db_connect.php'; 
include 'admin_auth.php'; 

// ফিল্টার স্টেট চেক করা
$filter = isset($_GET['view']) ? $_GET['view'] : 'all';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>NSU Panel | Admin Control</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { 
            --bg-deep: #0f172a; 
            --sidebar-bg: #1e293b;
            --nsu-gold: #fdb913;
            --accent-green: #22c55e;
            --accent-red: #ef4444;
            --text-main: #f8fafc;
            --card-glass: rgba(30, 41, 59, 0.7);
        }

        body { font-family: 'Inter', sans-serif; background: var(--bg-deep); margin: 0; display: flex; color: var(--text-main); min-height: 100vh; overflow-x: hidden; }
        
        .sidebar { width: 280px; height: 100vh; background: var(--sidebar-bg); color: white; position: fixed; padding: 30px 20px; box-sizing: border-box; border-right: 1px solid rgba(255,255,255,0.05); z-index: 1000; }
        .sidebar h2 { color: var(--nsu-gold); font-size: 1.4rem; margin-bottom: 40px; text-align: center; font-weight: 800; letter-spacing: 1px; }
        .nav-link { display: flex; align-items: center; color: #94a3b8; text-decoration: none; padding: 15px; border-radius: 12px; margin-bottom: 8px; transition: 0.3s; cursor: pointer; }
        .nav-link:hover { background: rgba(253, 185, 19, 0.1); color: var(--nsu-gold); }
        .nav-link.active { background: var(--nsu-gold); color: var(--bg-deep); font-weight: 700; }
        .nav-link i { margin-right: 12px; font-size: 1.2rem; width: 25px; }

        .main-content { margin-left: 280px; padding: 40px; width: calc(100% - 280px); box-sizing: border-box; }
        
        .tab-content { display: none; width: 100%; animation: fadeIn 0.4s ease; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-top: 20px; }
        .stat-card { background: var(--card-glass); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.05); backdrop-filter: blur(10px); cursor: pointer; transition: 0.3s; }
        .stat-card:hover { transform: translateY(-5px); border-color: var(--nsu-gold); }
        .active-filter { border: 2px solid var(--nsu-gold) !important; background: rgba(253, 185, 19, 0.1) !important; }
        
        .stat-card h3 { font-size: 0.8rem; color: #94a3b8; text-transform: uppercase; margin: 0; letter-spacing: 1px; }
        .stat-card p { font-size: 2.5rem; font-weight: 800; margin: 10px 0 0; }

        .card-table { background: var(--card-glass); border-radius: 24px; overflow: hidden; border: 1px solid rgba(255,255,255,0.05); margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; }
        th { background: rgba(0,0,0,0.2); padding: 20px; text-align: left; color: var(--nsu-gold); font-size: 0.8rem; text-transform: uppercase; }
        td { padding: 18px 20px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #cbd5e1; }
        
        .badge { padding: 5px 12px; border-radius: 6px; font-size: 0.7rem; font-weight: 700; }
        .badge-lost { background: rgba(239, 68, 68, 0.1); color: var(--accent-red); }
        .badge-found { background: rgba(34, 197, 94, 0.1); color: var(--accent-green); }
        .badge-recovered { background: var(--accent-green); color: #fff; }

        .form-group { margin-bottom: 20px; }
        .form-label { display: block; margin-bottom: 8px; color: #94a3b8; font-size: 0.9rem; }
        .form-input { width: 100%; padding: 14px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1); background: rgba(15, 23, 42, 0.6); color: #fff; font-size: 1rem; box-sizing: border-box; }
        .btn-save { background: var(--nsu-gold); color: var(--bg-deep); border: none; padding: 15px 30px; border-radius: 12px; font-weight: 800; cursor: pointer; transition: 0.3s; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>NSU PANEL</h2>
    <div class="nav-link <?= ($filter == 'all' && !isset($_GET['tab'])) ? 'active' : '' ?>" onclick="window.location.href='admin_dashboard.php?view=all'"><i class="fas fa-chart-pie"></i> Overview</div>
    <div class="nav-link <?= (isset($_GET['tab']) && $_GET['tab'] == 'items') ? 'active' : '' ?>" id="link-items" onclick="showTab('all-items', this)"><i class="fas fa-box-open"></i> All Items</div>
    <div class="nav-link" id="link-students" onclick="showTab('students', this)"><i class="fas fa-users"></i> Students</div>
    <div class="nav-link" id="link-settings" onclick="showTab('settings', this)"><i class="fas fa-sliders-h"></i> Settings</div>
    <a href="logout.php" class="nav-link" style="margin-top: 50px; color: #f87171;"><i class="fas fa-sign-out-alt"></i> Logout</a>
</div>

<div class="main-content">
    
    <div id="overview" class="tab-content active">
        <h1>System Analytics</h1>
        <p style="color: #64748b;">Click on a card to filter the items below.</p>
        
        <div class="stats-grid">
            <?php
            $total_c = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as c FROM items"))['c'];
            $recovered_c = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as c FROM items WHERE status IN ('recovered', 'completed')"))['c'];
            $instock_c = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as c FROM items WHERE status IN ('active', 'pending')"))['c'];
            $user_c = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as c FROM users"))['c'];
            ?>
            
            <div class="stat-card <?= $filter == 'all' ? 'active-filter' : '' ?>" onclick="window.location.href='admin_dashboard.php?view=all'">
                <h3>Total Reported</h3><p><?=$total_c?></p>
            </div>
            
            <div class="stat-card <?= $filter == 'recovered' ? 'active-filter' : '' ?>" onclick="window.location.href='admin_dashboard.php?view=recovered'">
                <h3>Recovered</h3><p style="color: var(--accent-green);"><?=$recovered_c?></p>
            </div>
            
            <div class="stat-card <?= $filter == 'instock' ? 'active-filter' : '' ?>" onclick="window.location.href='admin_dashboard.php?view=instock'">
                <h3>In Stock</h3><p style="color: var(--nsu-gold);"><?=$instock_c?></p>
            </div>
            
            <div class="stat-card" onclick="showTab('students', document.getElementById('link-students'))">
                <h3>Active Users</h3><p><?=$user_c?></p>
            </div>
        </div>

        <h2 style="margin-top: 50px; color: var(--nsu-gold); font-size: 1.2rem;">
            List View: <?= ($filter == 'all') ? 'All Items' : ($filter == 'recovered' ? 'Recovered Items' : 'In Stock Items') ?>
        </h2>
        
        <div class="card-table">
            <?php renderItemsTable($conn, 10, $filter); ?>
        </div>
    </div>

    <div id="all-items" class="tab-content">
        <h1>All Items Directory</h1>
        <div class="card-table"><?php renderItemsTable($conn, 100, 'all'); ?></div>
    </div>

    <div id="students" class="tab-content">
        <h1>Registered Students</h1>
        <div class="card-table">
            <table>
                <thead><tr><th>Name</th><th>Email</th><th>Student ID</th><th>Role</th></tr></thead>
                <tbody>
                    <?php
                    $u_res = mysqli_query($conn, "SELECT * FROM users ORDER BY created_at DESC");
                    while($u = mysqli_fetch_assoc($u_res)) {
                        echo "<tr><td><b style='color:#fff'>".htmlspecialchars($u['full_name'])."</b></td><td>".htmlspecialchars($u['email'])."</td><td>".htmlspecialchars($u['student_id'])."</td><td><span class='badge' style='background:rgba(255,255,255,0.1)'>".strtoupper($u['role'] ?? 'user')."</span></td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>

    <div id="settings" class="tab-content">
        <h1>Admin Settings</h1>
        <div class="stat-card" style="max-width: 600px;">
            <form action="update_admin.php" method="POST">
                <div class="form-group"><label class="form-label">Admin Name</label><input type="text" name="admin_name" class="form-input" value="<?= htmlspecialchars($_SESSION['full_name'] ?? '') ?>"></div>
                <div class="form-group"><label class="form-label">New Password</label><input type="password" name="new_pass" class="form-input" placeholder="Leave blank to stay same"></div>
                <button type="submit" class="btn-save">Save Profile</button>
            </form>
        </div>
    </div>
</div>

<?php
function renderItemsTable($conn, $limit, $filter) {
    $sql = "SELECT * FROM items";
    if ($filter == 'recovered') { $sql .= " WHERE status IN ('recovered', 'completed')"; } 
    elseif ($filter == 'instock') { $sql .= " WHERE status IN ('active', 'pending')"; }
    $sql .= " ORDER BY created_at DESC LIMIT $limit";
    $res = mysqli_query($conn, $sql);

    echo '<table><thead><tr><th>Item Name</th><th>Type</th><th>Status</th><th>Actions</th></tr></thead><tbody>';
    if(mysqli_num_rows($res) > 0) {
        while($row = mysqli_fetch_assoc($res)) {
            $type_badge = ($row['item_type'] == 'lost') ? 'badge-lost' : 'badge-found';
            $is_rec = (strtolower($row['status']) == 'recovered' || strtolower($row['status']) == 'completed');
            $status_ui = $is_rec ? '<span class="badge badge-recovered">COMPLETED</span>' : '<span style="color:#64748b">In Queue</span>';
            echo '<tr>
                    <td><strong style="color:#fff">'.htmlspecialchars($row['title']).'</strong></td>
                    <td><span class="badge '.$type_badge.'">'.strtoupper($row['item_type']).'</span></td>
                    <td>'.$status_ui.'</td>
                    <td>';
            if(!$is_rec) { echo '<a href="mark_recovered.php?id='.$row['item_id'].'" style="color:var(--accent-green); margin-right:15px; font-size:1.2rem;"><i class="fas fa-check-circle"></i></a>'; }
            echo '<a href="delete_handler.php?id='.$row['item_id'].'" style="color:var(--accent-red); font-size:1.1rem;" onclick="return confirm(\'Permanently delete this?\')"><i class="fas fa-trash-alt"></i></a></td></tr>';
        }
    } else { echo '<tr><td colspan="4" style="text-align:center; padding:30px; color:#64748b;">No data found.</td></tr>'; }
    echo '</tbody></table>';
}
?>

<script>
function showTab(tabId, element) {
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
    document.getElementById(tabId).classList.add('active');
    if(element) element.classList.add('active');
}

window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if(urlParams.has('view')) {
        showTab('overview', document.querySelector('.nav-link'));
    }
}
</script>
</body>
</html>