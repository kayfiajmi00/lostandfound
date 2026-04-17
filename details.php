<?php 
session_start();
include 'db_connect.php';
include 'header.php'; 

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
$current_user_id = $_SESSION['user_id'] ?? null;

// ১. ডাটাবেস কোয়েরি (আপনার টেবিল স্ট্রাকচার অনুযায়ী কলাম নেম আপডেট করা হয়েছে)
$query = "SELECT items.*, categories.category_name, users.full_name, users.email 
          FROM items 
          LEFT JOIN categories ON items.category_id = categories.category_id 
          LEFT JOIN users ON items.user_id = users.user_id
          WHERE items.item_id = $id"; 

$result = mysqli_query($conn, $query);
$item = mysqli_fetch_assoc($result);

if (!$item) { 
    echo "<div style='margin-top:150px; text-align:center; color:white;'><h2>Item Not Found</h2><a href='explore.php' style='color:#3b82f6;'>Back to Feed</a></div>";
    include 'footer.php'; exit; 
}

// ২. ইমেজ পাথ হ্যান্ডলিং (ডুপ্লিকেট 'uploads/' সমস্যা ফিক্স)
$img_db = $item['item_image'];
if (empty($img_db)) {
    $imagePath = 'img/default.jpg';
} else {
    // যদি ডাটাবেসে আগে থেকেই 'uploads/' লেখা থাকে, তবে নতুন করে যোগ করবে না
    if (strpos($img_db, 'uploads/') === 0) {
        $imagePath = $img_db;
    } else {
        $imagePath = 'uploads/' . $img_db;
    }
}

$is_owner = ($current_user_id && $current_user_id == $item['user_id']);
?>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    body { background: #0b1220; font-family: 'Outfit', sans-serif; color: white; }
    .details-wrapper { margin-top: 120px; margin-bottom: 100px; padding: 0 8%; min-height: 80vh; }
    .details-container { display: grid; grid-template-columns: 1fr 1fr; background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(15px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 30px; overflow: hidden; box-shadow: 0 25px 50px rgba(0,0,0,0.4); }
    .details-image { width: 100%; height: 100%; min-height: 500px; background-size: cover; background-position: center; border-right: 1px solid rgba(255, 255, 255, 0.1); }
    .details-info { padding: 50px; position: relative; }
    .tag { display: inline-block; padding: 6px 16px; border-radius: 100px; font-size: 0.75rem; font-weight: 800; text-transform: uppercase; margin-bottom: 15px; }
    .tag-found { background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.3); }
    .tag-lost { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid rgba(239, 68, 68, 0.3); }
    .description-box { background: rgba(255, 255, 255, 0.05); padding: 25px; border-radius: 20px; margin: 25px 0; line-height: 1.6; color: #cbd5e1; border: 1px solid rgba(255, 255, 255, 0.05); }
    .chat-wrapper { margin-top: 30px; background: rgba(255, 255, 255, 0.02); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); }
    .chat-input-style { width: 100%; padding: 12px; border-radius: 10px; background: #0b1220; color: white; border: 1px solid rgba(255,255,255,0.1); margin-bottom: 10px; font-family: inherit; outline: none; transition: 0.3s; }
    .q-label { font-size: 0.8rem; color: #cbd5e1; display: block; margin-bottom: 5px; font-weight: 600; }
    .btn-custom { padding: 12px 28px; border-radius: 14px; text-decoration: none; font-weight: 700; transition: 0.3s; display: inline-block; border: none; cursor: pointer; text-align: center; }
    .btn-primary { background: #3b82f6; color: white; width: 100%; }
    .contact-revealed { background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.3); padding: 20px; border-radius: 20px; margin-top: 20px; }
</style>

<div class="details-wrapper">
    <div class="details-container">
        <div class="details-image" style="background-image: url('<?php echo htmlspecialchars($imagePath); ?>');"></div>
        
        <div class="details-info">
            <span class="tag tag-<?php echo strtolower($item['item_type']); ?>"><?php echo strtoupper($item['item_type']); ?></span>
            
            <h1 style="font-size: 2.2rem; font-weight: 800; margin-bottom: 15px;"><?php echo htmlspecialchars($item['title']); ?></h1>
            <p style="color: #94a3b8;">📍 <strong>Location:</strong> <?php echo htmlspecialchars($item['location_name']); ?></p>

            <div class="description-box">
                <h4 style="color:#3b82f6; margin-bottom:8px;">Description</h4>
                <p><?php echo nl2br(htmlspecialchars($item['description'])); ?></p>
            </div>

            <?php if (!$is_owner && $current_user_id): ?>
                <div id="verification-area" class="chat-wrapper">
                    <h4 style="color: #fdb913; margin-bottom: 15px;"><i class="fa-solid fa-shield-halved"></i> Security Check</h4>
                    
                    <label class="q-label">Main Question:</label>
                    <p style="font-size: 0.9rem; color: #fdb913; margin-bottom: 10px; font-weight: 700;">
                        <?php echo htmlspecialchars($item['main_security_question'] ?? 'No security question set.'); ?>
                    </p>
                    <input type="text" id="ans_main" placeholder="Type answer..." class="chat-input-style">
                    
                    <button onclick="verifyAccess()" class="btn-custom btn-primary" style="margin-top:15px;">Verify Identity</button>
                </div>

                <div id="email-reveal-box" class="contact-revealed" style="display:none;">
                    <h4 style="color:#10b981;"><i class="fa-solid fa-circle-check"></i> Verified!</h4>
                    <p>Reporter: <strong><?php echo htmlspecialchars($item['full_name']); ?></strong></p>
                    <p>Email: <strong style="color: #fdb913;"><?php echo htmlspecialchars($item['email']); ?></strong></p>
                </div>

                <div id="chat-box-area" class="chat-wrapper" style="display: none;">
                    <h4 style="color: #3b82f6; margin-bottom: 15px;"><i class="fa-solid fa-comments"></i> Send Message</h4>
                    <textarea id="msg_input" class="chat-input-style" rows="3" placeholder="Write your message..."></textarea>
                    <button id="send-btn" onclick="sendMessage(<?php echo $item['item_id']; ?>, <?php echo $item['user_id']; ?>)" class="btn-custom btn-primary">Send</button>
                </div>
            <?php elseif ($is_owner): ?>
                <div class="chat-wrapper">
                    <p style="text-align:center; color: #3b82f6;">You are the owner of this post.</p>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<script>
function verifyAccess() {
    const realMain = "<?php echo addslashes($item['security_answer'] ?? ''); ?>".toLowerCase().trim();
    const userMain = document.getElementById('ans_main').value.toLowerCase().trim();

    if (userMain !== realMain) {
        Swal.fire('Error', 'Answer incorrect! Please try again.', 'error');
        return;
    }

    // সাকসেস হলে হাইড এবং শো করা
    document.getElementById('verification-area').style.display = 'none';
    document.getElementById('email-reveal-box').style.display = 'block';
    document.getElementById('chat-box-area').style.display = 'block';
    
    Swal.fire('Success', 'Identity Verified!', 'success');
}

async function sendMessage(itemId, receiverId) {
    const msgInput = document.getElementById('msg_input');
    const msg = msgInput.value.trim();
    if (!msg) return;
    try {
        const response = await fetch('send_message.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `item_id=${itemId}&receiver_id=${receiverId}&message=${encodeURIComponent(msg)}`
        });
        const text = await response.text();
        if (text.trim() === "Success") {
            msgInput.value = "";
            Swal.fire('Sent!', 'Message delivered!', 'success');
        }
    } catch (e) { Swal.fire('Error', 'Server error', 'error'); }
}
</script>

<?php include 'footer.php'; ?>