<html>

 <head>

    <title>Welcome to Jacose</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href = "css/bootstrap.css" rel = "stylesheet">

    <link href = "css/styles.css" rel = "stylesheet">

    <link href = "css/style.css" rel = "stylesheet">
   </head>

<body>

<?php 


$mysqli = new mysqli("host", "user", "password", "database", 3360);

$rquery = $mysqli->query("SELECT * FROM key_hash");	

$usergroups = array(
	"superadmin",
	"admin",
	"moderator",
	"vip"
);

if(isset($_POST["generatekey"])){
	if(isset($_POST["rank"])){
	$rank = $mysqli->real_escape_string($_POST["rank"]);
	if(in_array($rank, $usergroups)){
	$skey = generateRandomString(25);
	generatekey($skey, $rank, $mysqli);
	}else{
		if($rank == "ass"){
			echo "Yes you are an..";
		}else{
		echo "The rank doesn't exist!";
		}
	}
 }
}

function generatekey($string, $rank, $mysqli){

	$rows = $mysqli->query("SELECT * FROM key_hash")->num_rows;
	$new = "$string$rows";
	$escaped_rank = $mysqli->real_escape_string($rank);
	$test = $mysqli->query("INSERT INTO `key_hash`(`hash`, `reward`) VALUES ('$new','$escaped_rank')"); 
	echo $rows;
}	


//This is taken from somewhere
// http://stackoverflow.com/questions/4356289/php-random-string-generator
function generateRandomString($length) {

    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    $charactersLength = strlen($characters);

    $randomString = '';

    for ($i = 0; $i < $length; $i++) {

        $randomString .= $characters[rand(0, $charactersLength - 1)];

    }

    return $randomString;

}
?> 



<center>
	<div id="table_">
		<table>

			<?php if($rquery->num_rows > 0){ ?>
				
				<li><a>The table is populated</a></li>

			<?php while($row = $rquery->fetch_assoc()){?>

				<li><a><?php echo $rquery->fetch_array(MYSQLI_BOTH)["hash"];}}?></a></li>
				
		</table>
	</div>
	<form action="" method="post">
	<input  style='padding:7px;' type='text' name='rank' style='padding:4px;'/>
	<input  style='padding:7px;' onclick="" type='submit' value='Generate Key' name='generatekey'/>
	</form>
	
</center>	

	<script src = 'http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
	<script src = 'js/bootstrap.js'></script>  
 </body>

</html>

