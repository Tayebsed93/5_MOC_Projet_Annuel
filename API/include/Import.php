<?php
//index.php
require_once dirname(__FILE__) . '/DbHandler.php';
require_once("header.php");
$connect = mysqli_connect("mysql.hostinger.fr", "u263286397_poubc", "Sevran93270!", "u263286397_poubc");
$message = '';

if(isset($_POST["upload"]))
{
 if($_FILES['product_file']['name'])
 {
  $filename = explode(".", $_FILES['product_file']['name']);
  if(end($filename) == "csv")
  {
   $handle = fopen($_FILES['product_file']['tmp_name'], "r");
   while($data = fgetcsv($handle))
   {

    

    $player = $data[0];
    $nation = mysqli_real_escape_string($connect, $data[1]);  
                $competition_id = mysqli_real_escape_string($connect, $data[2]);

 
    
$data = array("player" => $player, "nation" => $nation, "competition_id" => $competition_id); // POST data included in your query
$ch = curl_init("http://poubelle-connecte.pe.hu/FootAPI/API/v1/compositionCSV"); // Set url to query 

curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST"); // Send via POST                                         
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data)); // Set POST data                                  
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // Return response text   
curl_setopt($ch, CURLOPT_HEADER, "Content-Type: application/x-www-form-urlencoded"); // send POST data as form data

$response = curl_exec($ch);
curl_close($ch);

   }
   fclose($handle);
   //header("location: index.php?updation=1");
  }
  else
  {
   $message = '<label class="text-danger">Fichier CSV uniquement</label>';
  }
 }
 else
 {
  $message = '<label class="text-danger">Veuillez sélectionner un fichier</label>';
 }
}

if(isset($_GET["updation"]))
{
 $message = '<label class="text-success">Fichier enrengistré avec succès</label>';
}

$ch = curl_init("http://poubelle-connecte.pe.hu/FootAPI/API/v1/compositionCSV"); // Set url to query 

curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET"); // Send via POST                                         
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data)); // Set POST data                                  
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // Return response text   
curl_setopt($ch, CURLOPT_HEADER, "Content-Type: application/x-www-form-urlencoded"); // send POST data as form data

$response = curl_exec($ch);
curl_close($ch);

$query = "SELECT c.*, uc.* FROM composition c, user_composition uc WHERE uc.composition_id = c.id AND nation != 'nation' AND player  != 'player' AND uc.user_id = 42";
$result = mysqli_query($connect, $query);

?>
<!DOCTYPE html>
<html>
 <head>
  <title>MyFoot</title>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" />
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
 </head>
 <body>
  <br />
  <div class="container">
   <h1 align="center">MyFoot - Ajouter une composition</a></h1>
   <br />
   <form method="post" enctype='multipart/form-data'>
    <p><label>Veuillez selectionner un fichier (Format CSV seulement)</label>
    <input type="file" name="product_file" /></p>
    <br />
    <input type="submit" name="upload" class="btn btn-info" value="Envoyer" />
   </form>
   <br />
   <?php echo $message; ?>
   <h1 align="center">Composition enregistré</h1>
   <br />
   <div class="starter-template">
    <table class="table table-bordered table-striped">
    <thead class="thead-dark">
     <tr>
      <th>ID</th>
      <th>Joueur composition</th>
      <th>Pays</th>
     </tr>
     </thead>
     <?php
     while($row = mysqli_fetch_array($result))
     {
      echo '
      <tr>
        <td>'.$row["id"].'</td>
       <td>'.$row["nation"].'</td>
       <td>'.$row["player"].'</td>
      </tr>
      ';
     }
     ?>
    </table>
   </div>



  </div>
 </body>
</html>
