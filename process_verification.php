<?php
include 'db_connect.php';
session_start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit;
}

$item_id = intval($_POST['item_id']);

// ইনপুট থেকে উত্তরগুলো নেওয়া
$user_main_ans = isset($_POST['main_answer']) ? strtolower(trim($_POST['main_answer'])) : '';
$user_optional_answers = isset($_POST['answers']) ? $_POST['answers'] : [];

// ডাটাবেস থেকে সঠিক উত্তরগুলো আনা
$query = "SELECT * FROM items WHERE item_id = $item_id";
$res = mysqli_query($conn, $query);
$item = mysqli_fetch_assoc($res);

if (!$item) {
    header("Location: explore.php");
    exit;
}

// মেইন উত্তর চেক (security_answer বা main_answer কলাম চেক করা হচ্ছে)
$real_main_ans = strtolower(trim($item['main_answer'] ?? $item['security_answer'] ?? ''));
$main_correct = ($user_main_ans === $real_main_ans);

// অপশনাল স্কোরিং (৪টি ছোট প্রশ্ন চেক করা)
$score = 0;
for ($i = 1; $i <= 4; $i++) {
    $real_ans = strtolower(trim($item["a$i"] ?? $item["ans$i"] ?? ''));
    $submitted_ans = isset($user_optional_answers[$i]) ? strtolower(trim($user_optional_answers[$i])) : '';

    if (!empty($real_ans) && $submitted_ans === $real_ans) {
        $score++;
    }
}

/** * নতুন লজিক অনুযায়ী রিডাইরেক্ট:
 * ১. মেইন + ৩টি সঠিক = full (ইমেইল + মেসেজ বাটন)
 * ২. শুধু মেইন সঠিক = partial (শুধু মেসেজ বাটন, ইমেইল থাকবে না)
 * ৩. মেইন ভুল কিন্তু ৩টি সঠিক = contact_only (শুধু ইমেইল দেখাবে)
 */
if ($main_correct && $score >= 3) {
    header("Location: details.php?id=$item_id&verify=full");
} elseif ($main_correct) {
    header("Location: details.php?id=$item_id&verify=partial");
} elseif ($score >= 3) {
    header("Location: details.php?id=$item_id&verify=contact_only");
} else {
    header("Location: details.php?id=$item_id&verify=failed");
}
exit;
?>