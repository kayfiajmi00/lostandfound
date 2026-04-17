<?php
include 'db_connect.php';
session_start();

// ১. চেক করুন ইউজার লগ-ইন করা কি না
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

$item_id = isset($_GET['item_id']) ? intval($_GET['item_id']) : 0;

// ২. আইটেম ডাটা ফেচ করা
$query = "SELECT items.*, users.email, users.phone 
          FROM items 
          JOIN users ON items.user_id = users.user_id 
          WHERE items.item_id = $item_id";
$result = mysqli_query($conn, $query);
$item = mysqli_fetch_assoc($result);

if (!$item) { 
    header("Location: explore.php"); 
    exit; 
}

// ৩. প্রশ্নের লিস্ট তৈরি করা
$questions = [];
for ($i = 1; $i <= 4; $i++) {
    if (!empty($item["q$i"])) {
        $questions[$i] = $item["q$i"];
    }
}

include 'header.php';
?>

<main style="margin-top: 120px; padding: 20px 10%; min-height: 80vh; background: #0b1220; color: white; font-family: 'Inter', sans-serif;">
    <div style="max-width: 600px; margin: auto; background: #161e2d; padding: 40px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 20px 40px rgba(0,0,0,0.3);">
        
        <h2 style="color: #fdb913; margin-bottom: 10px;">
            <i class="fa-solid fa-shield-halved"></i> Security Challenge 🔒
        </h2>
        <p style="color: #94a3b8; margin-bottom: 25px;">The reporter has set a specific challenge to verify ownership.</p>
        
        <div style="background: rgba(59, 130, 246, 0.1); padding: 15px; border-radius: 10px; margin-bottom: 25px; border-left: 4px solid #3b82f6;">
            <ul style="margin: 0; padding-left: 20px; color: #cbd5e1; font-size: 0.85rem; line-height: 1.6;">
                <li><strong style="color: #3b82f6;">Level 1:</strong> Correct <b>Main Question</b> = Unlock Messaging.</li>
                <li><strong style="color: #22c55e;">Level 2:</strong> Correct <b>Main + 3 Optional</b> = Reveal Owner's Email/Phone.</li>
            </ul>
        </div>

        <form action="process_verification.php" method="POST">
            <input type="hidden" name="item_id" value="<?php echo $item_id; ?>">
            
            <div style="margin-bottom: 25px;">
                <label style="display:block; font-weight:700; margin-bottom:10px; color: #fdb913;">
                    MAIN QUESTION (Mandatory):
                </label>
                <div style="background: #0b1220; padding: 15px; border-radius: 8px; margin-bottom: 10px; border: 1px solid rgba(255,255,255,0.05);">
                    <?php echo htmlspecialchars($item['main_security_question'] ?? 'Please provide a detailed description.'); ?>
                </div>
                <input type="text" name="main_answer" placeholder="Type your answer here..." required 
                       style="width:100%; padding:14px; border:1px solid #334155; background:#0b1220; color:white; border-radius:10px; outline: none;">
            </div>

            <?php if (!empty($questions)): ?>
                <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.05); margin-bottom: 25px;">
                <p style="color: #94a3b8; font-size: 0.9rem; margin-bottom: 20px;">Optional: Answer at least 3 to reveal direct contact info.</p>
                
                <?php foreach ($questions as $num => $q_text): ?>
                    <div style="margin-bottom: 20px;">
                        <label style="display:block; font-weight:600; margin-bottom:8px; color: #cbd5e1;">
                            Q<?php echo $num; ?>: <?php echo htmlspecialchars($q_text); ?>
                        </label>
                        <input type="text" name="answers[<?php echo $num; ?>]" 
                               placeholder="Your answer..." 
                               style="width:100%; padding:12px; border:1px solid #334155; background:#0b1220; color:white; border-radius:8px; outline: none;">
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>

            <div style="display: flex; gap: 10px; margin-top: 35px;">
                <button type="submit" style="flex: 2; background: #3b82f6; color:white; border:none; padding:16px; border-radius:12px; cursor:pointer; font-weight: 700; font-size: 1rem; transition: 0.3s;">
                    Submit for Verification
                </button>
                <a href="details.php?id=<?php echo $item_id; ?>" 
                   style="flex: 1; background: #334155; color:white; text-decoration: none; text-align: center; padding: 16px; border-radius: 12px; font-weight: 600;">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</main>