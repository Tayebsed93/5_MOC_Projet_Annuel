<?php
require_once dirname(__FILE__) . '/DbHandler.php';
session_start();
 


if (isset($_POST['import'])) {
    $file = $_POST['file'];
    $content_dir = $_POST['content_dir'];
    $name_file = $_POST['name_file'];
 
    if (file_exists($file))
        $fp = fopen("$file", "r");
    else { /* le fichier n'existe pas */
        echo "Fichier introuvable !<br>Importation stoppée.";
        exit();
    }
    
    
    $ligne = fgets($fp, 4096);

        $row = 1;
                while (($data = fgetcsv($fp, 1000, ",")) !== FALSE) {
                $num = count($data);
                //echo "<p> $num champs à la ligne $row: <br /></p>\n";
                echo "<p> <br /></p>";
                $row++;
                for ($c=0; $c < $num; $c++) {
                //echo $data[$c] . "<br />\n";
        }
        $player = $data[0];
        $nation = $data[1];
        $competition_id = $data[2];

        $db = new DbHandler();
        $res = $db->importCompoCSV($player, $nation, $competition_id);

    }
    fclose($handle);

}
 
 
if (isset($_POST['upload'])) {
    if (empty($_FILES['fichiercsv']['tmp_name'])) {
        echo '<strong>Choose a CSV FILE !!</strong>';
    } else {
        $racine = (!empty($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . '/';
        $content_dir = __DIR__ . '/CSVFolder/';
        $tmp_file = $_FILES['fichiercsv']['tmp_name'];
        if (!is_uploaded_file($tmp_file)) {
            exit("The file is lost");
        }
        $type_file = $_FILES['fichiercsv']['type'];
        $extensions_valides = array('csv', 'txt');
        $extension_upload = substr(strrchr($_FILES['fichiercsv']['name'], '.'), 1);
        if (in_array($extension_upload, $extensions_valides)) {
            // on copie le fichier dans le dossier de destination
            $name_file = $_FILES['fichiercsv']['name'];
            if (!move_uploaded_file($tmp_file, $content_dir . $name_file)) {
                exit("Impossible to copy the file to $content_dir");
            }
            $file = "$content_dir" . "$name_file";
            if (file_exists($file)) {
                $fic = fopen($file, 'rb');
                echo "<table border='1' style='width: 100%'><caption>Preview before import</caption>\n";
                for ($ligne = fgetcsv($fic, 1024); !feof($fic); $ligne = fgetcsv($fic, 1024)) {
                    echo "<tr>";
                    $j = sizeof($ligne);
                    for ($i = 0; $i < $j; $i++) {
                        
                        echo "<td>$ligne[$i]</td>";
                    }
                    echo "</tr>";
                }
                echo "</table>\n";
?>
                <form action="index.php">
                    <input type="submit" value="Cancel">
                </form>
                <form action="" name="import" method="post">
                    <input type="hidden" name="file" value="<?php echo $file; ?>">
                    <input type="hidden" name="content_dir" value="<?php echo $content_dir; ?>">
                    <input type="hidden" name="name_file" value="<?php echo $name_file; ?>">
                    <input type="hidden" name="import" value="ok">
                    <input type="submit"  value ="Import into database">
                </form>
 
<?php
                return;
            } else {
                exit("NO FILE EXIST");
            }
        } else {
            echo "incorrect file. You must upload <strong>csv file</strong> or <strong>txt file. </strong>";
        }
    }
}
?>
<html>
    <head></head>
    <body>
        <form method="link" action="../sales.php" >
            <input  type="submit" value="back">
        </form>
        <form action="" name="form_bdd" id="form_bdd" method="post" enctype="multipart/form-data">
            <input type="hidden" name="upload" value="ok">
            <input type="file" name="fichiercsv" size="16">
            <input type="submit" value="Upload">
        </form>
    </body>
</html>