// jQuery & Velocity.js

function slideUpIn() {
  $("#login").velocity("transition.slideUpIn", 1250)
};

function slideLeftIn() {
  $(".row").delay(500).velocity("transition.slideLeftIn", {stagger: 500})    
}

function shake() {
  $(".password-row").velocity("callout.shake");
}

slideUpIn();
slideLeftIn();
$("button").on("click", function () {
 var email = document.getElementById("username_input").value;
 var password = document.getElementById("password_input").value;
 //console.log(password);
  if (email == "myfoot@gmail.com" && password == "esgi")  {
    //window.location("www.google.fr");
    window.location = 'Import.php';
  }
  else {
    var msg="Identifiant ou mot de passe incorrecte";
       alert(msg);
       shake();
  }
  
});