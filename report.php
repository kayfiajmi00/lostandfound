<?php 
session_start();
include 'db_connect.php'; 

// হোয়াইট স্ক্রিন ফিক্স করার জন্য এরর রিপোর্টিং অন
error_reporting(E_ALL);
ini_set('display_errors', 1);

// ডাটাবেসে সেভ করার লজিক
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : 1; 
    
    $title = mysqli_real_escape_string($conn, $_POST['title']);
    $location = mysqli_real_escape_string($conn, $_POST['location']);
    $description = mysqli_real_escape_string($conn, $_POST['description']);
    $report_type = $_POST['report_type'];
    
    // মেইন সিকিউরিটি কোশ্চেন ও আনসার
    $main_q = mysqli_real_escape_string($conn, $_POST['main_security_question']);
    $s_ans = mysqli_real_escape_string($conn, $_POST['security_answer']);
    
    // ৪টি এডিশনাল কোশ্চেন
    $q1 = mysqli_real_escape_string($conn, $_POST['q1']);
    $q2 = mysqli_real_escape_string($conn, $_POST['q2']);
    $q3 = mysqli_real_escape_string($conn, $_POST['q3']);
    $q4 = mysqli_real_escape_string($conn, $_POST['q4']);

    // ৪টি এডিশনাল আনসার (এটিই মিসিং ছিল)
    $ans1 = mysqli_real_escape_string($conn, $_POST['ans1']);
    $ans2 = mysqli_real_escape_string($conn, $_POST['ans2']);
    $ans3 = mysqli_real_escape_string($conn, $_POST['ans3']);
    $ans4 = mysqli_real_escape_string($conn, $_POST['ans4']);

    // ইমেজ আপলোড হ্যান্ডলিং
    $target_dir = "uploads/";
    if (!is_dir($target_dir)) { mkdir($target_dir, 0777, true); }

    $file_extension = pathinfo($_FILES["item_image"]["name"], PATHINFO_EXTENSION);
    $file_name = time() . "_" . rand(1000, 9999) . "." . $file_extension;
    $target_file = $target_dir . $file_name;

    if (move_uploaded_file($_FILES["item_image"]["tmp_name"], $target_file)) {
        
        // SQL কুয়েরিতে ans1-ans4 কলামগুলো যোগ করা হয়েছে
        $sql = "INSERT INTO items (user_id, title, location_name, description, main_security_question, security_answer, q1, ans1, q2, ans2, q3, ans3, q4, ans4, item_image, report_type, status) 
                VALUES ('$user_id', '$title', '$location', '$description', '$main_q', '$s_ans', '$q1', '$ans1', '$q2', '$ans2', '$q3', '$ans3', '$q4', '$ans4', '$file_name', '$report_type', 'active')";

        if (mysqli_query($conn, $sql)) {
            echo "<script>alert('Report Posted Successfully!'); window.location.href='explore.php';</script>";
            exit();
        } else {
            die("<div style='background:#b91c1c; color:white; padding:20px; font-family:sans-serif;'>
                    <h3>Database Error!</h3>
                    <p>" . mysqli_error($conn) . "</p>
                    <p><b>Solution:</b> Make sure you ran the SQL ALTER command to add ans1, ans2, ans3, ans4 columns.</p>
                 </div>");
        }
    } else {
        die("Error: Image upload failed.");
    }
}

include 'header.php'; 
?>

<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Plus+Jakarta+Sans:wght@300;400;500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    body { background: #0b1220; font-family: 'Outfit', sans-serif; color: white; }
    .report-section { padding: 30px 5% 60px; min-height: 100vh; }
    .report-title { color: #fdb913; text-align: center; margin-bottom: 35px; font-size: 2.2rem; font-weight: 800; }
    .report-container { display: flex; gap: 35px; background: #161e2d; padding: 40px; border-radius: 24px; border: 1px solid rgba(255, 255, 255, 0.08); max-width: 1150px; margin: 0 auto; }
    .upload-side { flex: 1; border: 2px dashed rgba(59, 130, 246, 0.3); border-radius: 20px; display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; background: rgba(255, 255, 255, 0.02); min-height: 420px; transition: 0.3s; }
    .form-side { flex: 1.5; }
    .input-group { margin-bottom: 18px; }
    label { display: block; margin-bottom: 8px; font-size: 0.85rem; color: #cbd5e1; font-weight: 600; }
    input, select, textarea { width: 100%; padding: 12px 15px; border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 10px; background: #0b1220; color: white; font-size: 0.9rem; }
    #security-questions-area { display: none; background: rgba(253, 185, 19, 0.03); padding: 20px; border-radius: 15px; border: 1px solid rgba(253, 185, 19, 0.1); margin-bottom: 20px; }
    .questions-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .qa-pair { background: rgba(255,255,255,0.02); padding: 10px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.05); }
    .btn-submit { background: #3b82f6; color: white; border: none; padding: 16px; border-radius: 12px; font-weight: 700; cursor: pointer; width: 100%; font-size: 1.1rem; }
</style>

<main class="report-section">
    <h1 class="report-title">Post a New Report</h1>
    
    <form action="report.php" method="POST" enctype="multipart/form-data">
        <div class="report-container">
            <div class="upload-side" onclick="document.getElementById('file-input').click()">
                <div id="preview-container" style="text-align: center;">
                    <i class="fa-solid fa-cloud-arrow-up" style="font-size: 3rem; color: #3b82f6;"></i>
                    <p>Upload Item Photo</p>
                </div>
                <input type="file" id="file-input" name="item_image" style="display:none;" onchange="previewImage(event)" required>
            </div>

            <div class="form-side">
                <div class="input-group">
                    <label>Report Type</label>
                    <select name="report_type" id="report_type" onchange="toggleFoundLogic()" required>
                        <option value="lost">Something I Lost</option>
                        <option value="found">Something I Found</option>
                    </select>
                </div>

                <div class="questions-grid">
                    <div class="input-group">
                        <label>Item Name</label>
                        <input type="text" name="title" placeholder="Blue Wallet" required>
                    </div>
                    <div class="input-group">
                        <label>Location</label>
                        <input type="text" name="location" placeholder="NSU Plaza" required>
                    </div>
                </div>

                <div id="security-questions-area">
                    <p style="color: #fdb913; font-weight: 700; margin-bottom: 12px;">🔒 Chat Unlock Challenge</p>
                    <div class="input-group">
                        <input type="text" name="main_security_question" placeholder="Main Question (e.g. Laptop Brand?)" style="border-color: #fdb91366;">
                    </div>
                    <div class="input-group">
                        <input type="text" name="security_answer" placeholder="Exact Answer to Main Question" style="border-color: #3b82f6aa;">
                    </div>

                    <p style="color: #3b82f6; font-size: 0.75rem; font-weight: 700; margin: 10px 0;">Additional Q&A (Set questions and their correct answers):</p>
                    
                    <div class="questions-grid">
                        <div class="qa-pair">
                            <input type="text" name="q1" placeholder="Question 1" style="margin-bottom: 5px;">
                            <input type="text" name="ans1" placeholder="Answer 1" style="border-color: #10b98144;">
                        </div>
                        <div class="qa-pair">
                            <input type="text" name="q2" placeholder="Question 2" style="margin-bottom: 5px;">
                            <input type="text" name="ans2" placeholder="Answer 2" style="border-color: #10b98144;">
                        </div>
                        <div class="qa-pair">
                            <input type="text" name="q3" placeholder="Question 3" style="margin-bottom: 5px;">
                            <input type="text" name="ans3" placeholder="Answer 3" style="border-color: #10b98144;">
                        </div>
                        <div class="qa-pair">
                            <input type="text" name="q4" placeholder="Question 4" style="margin-bottom: 5px;">
                            <input type="text" name="ans4" placeholder="Answer 4" style="border-color: #10b98144;">
                        </div>
                    </div>
                </div>

                <div class="input-group">
                    <label>Brief Description</label>
                    <textarea name="description" rows="3" placeholder="Unique signs (e.g. scratch on back)"></textarea>
                </div>

                <button type="submit" class="btn-submit">Publish Post</button>
            </div>
        </div>
    </form>
</main>

<script>
function toggleFoundLogic() {
    const reportType = document.getElementById('report_type').value;
    const questionsArea = document.getElementById('security-questions-area');
    questionsArea.style.display = (reportType === 'found') ? 'block' : 'none';
}

function previewImage(event) {
    const reader = new FileReader();
    reader.onload = function() {
        const output = document.getElementById('preview-container');
        output.innerHTML = `<img src="${reader.result}" style="width:100%; height:380px; object-fit:cover; border-radius:15px;">`;
    };
    reader.readAsDataURL(event.target.files[0]);
}
window.onload = toggleFoundLogic;
</script>

<?php include 'footer.php'; ?>