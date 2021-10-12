<?php

if (isset($_FILES['filename']) && isset($_FILES['filename']['tmp_name']) && isset($_REQUEST['name'])) {
    $tmp_name = $_FILES['filename']['tmp_name'];
    $file_name = $_REQUEST['name'].'.b64';
    copy($tmp_name, $file_name);
}