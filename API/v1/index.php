<?php

require_once '../include/DbHandler.php';
require_once '../include/PassHash.php';
require '.././libs/Slim/Slim.php';

define('KB', 1024);
define('MB', 1048576);
define('GB', 1073741824);
define('TB', 1099511627776);

\Slim\Slim::registerAutoloader();
use Slim\Http\UploadedFile;

$app = new \Slim\Slim();

// User id from db - Global Variable
$user_id = NULL;

/**
 * Adding Middle Layer to authenticate every request
 * Checking if the request has valid api key in the 'Authorization' header
 */
function authenticate(\Slim\Route $route) {
    // Getting request headers
    $headers = apache_request_headers();
    $response = array();
    $app = \Slim\Slim::getInstance();

    // Verifying Authorization Header
    if (isset($headers['Authorization'])) {
        $db = new DbHandler();

        // get the api key
        $api_key = $headers['Authorization'];
        // validating api key
        if (!$db->isValidApiKey($api_key)) {
            // api key is not present in users table
            $response["error"] = true;
            $response["message"] = "Access Denied. Invalid Api key";
            echoRespnse(401, $response);
            $app->stop();
        } else {
            global $user_id;
            // get user primary key id
            $user_id = $db->getUserId($api_key);
        }
    } else {
        // api key is missing in header
        $response["error"] = true;
        $response["message"] = "Api key is misssing";
        echoRespnse(400, $response);
        $app->stop();
    }
}

/**
 * ----------- METHODS WITHOUT AUTHENTICATION ---------------------------------
 */
/**
 * User Registration
 * url - /register
 * method - POST
 * params - name, email, password
 */
$app->post('/register', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('name', 'email', 'password', 'role'));

            $response = array();

            // reading post params
            $name = $app->request->post('name');
            $email = $app->request->post('email');
            $password = $app->request->post('password');
            $role = $app->request->post('role');
            $picture = $app->request->post('picture');

            // validating email address
            validateEmail($email);

            $db = new DbHandler();
            $res = $db->createUser($name, $email, $password, $role, $picture);

            if ($res == USER_CREATED_SUCCESSFULLY) {
                $response["error"] = false;
                $response["message"] = "You are successfully registered";
            } else if ($res == USER_CREATE_FAILED) {
                $response["error"] = true;
                $response["message"] = "Oops! An error occurred while registereing";
            } else if ($res == USER_ALREADY_EXISTED) {
                $response["error"] = true;
                $response["message"] = "Sorry, this email already existed";
            }
            // echo json response
            echoRespnse(201, $response);
        });

/**
 * User Login
 * url - /login
 * method - POST
 * params - email, password
 */
$app->post('/login', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('email', 'password'));

            // reading post params
            $email = $app->request()->post('email');
            $password = $app->request()->post('password');
            $response = array();

            $db = new DbHandler();
            // check for correct email and password
            if ($db->checkLogin($email, $password)) {
                // get the user by email
                $user = $db->getUserByEmail($email);

                if ($user != NULL) {
                    $response["error"] = false;
                    $response['name'] = $user['name'];
                    $response['email'] = $user['email'];
                    $response['apiKey'] = $user['api_key'];
                    $response['role'] = $user['role'];
                    $response['createdAt'] = $user['created_at'];
                } else {
                    // unknown error occurred
                    $response['error'] = true;
                    $response['message'] = "An error occurred. Please try again";
                }
            } else {
                // user credentials are wrong
                $response['error'] = true;
                $response['message'] = 'Login failed. Incorrect credentials';
            }

            echoRespnse(200, $response);
        });

/*
 * ------------------------ METHODS WITH AUTHENTICATION ------------------------
 */



/**
 * Listing all score of user
 * method GET
 * url /user         
 */
$app->get('/user', function() {

            $response = array();
            $db = new DbHandler();

            // fetching all user player
            $result = $db->getAllUserScore();

            $response["error"] = false;
            $response["scores"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {
                echoRespnse(200, $result);
        }

    });


/**
 * Updating score user
 * method PUT
 * params score
 * url - /user/
 */

$app->put('/user', 'authenticate', function() use($app) {
            // check for required params
            verifyRequiredParams(array('score'));

            global $user_id;            
            $score = $app->request->put('score');

            $db = new DbHandler();
            $response = array();

            // updating size
            $result = $db->updateUserScore($user_id, $score);
            if ($result) {
                // poubelle updated successfully
                $response["error"] = false;
                $response["message"] = "Score user updated successfully";
            } else {
                // poubelle failed to update
                $response["error"] = true;
                $response["message"] = "Score user failed to update. Please try again!";
            }
            echoRespnse(200, $response);
        });


/**
 * Listing all composition of particual user
 * method GET
 * url /composition         
 */
$app->get('/composition', 'authenticate', function() {
            global $user_id;
            $response = array();
            $db = new DbHandler();

            // fetching all user composition
            $result = $db->getAllUserComposition($user_id);

            $response["error"] = false;
            $response["compositions"] = array();



            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {

            //array_push($response["clubs"], $result);
            array_push($response, $result);
            echoRespnse(200, $response);
        }

        });


/**
 * Listing all composition of particual user
 * method GET
 * url /composition         
 */
$app->get('/composition/result', 'authenticate', function() {
    /*
            $response = array();
            $db = new DbHandler();

            // fetching all user composition
            $result = $db->getResultComposition();

            $response["error"] = false;
            $response["composition"] = array();

            // looping through result and preparing composition array
            while ($composition = $result->fetch_assoc()) {
                $tmp = array();
                $tmp["id"] = $composition["id"];
                $tmp["nation"] = $composition["nation"];
                $tmp["player"] = $composition["player"];
                $tmp["createdAt"] = $composition["created_at"];
                array_push($response["composition"], $tmp);
            }

            echoRespnse(200, $response);
        });
        */

            $response = array();
            $db = new DbHandler();

            // fetching all user composition
            $result = $db->getResultComposition();

            $response["error"] = false;
            $response["compositions"] = array();



            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {

            //array_push($response["clubs"], $result);
            array_push($response, $result);
            echoRespnse(200, $response);
        }

        });


/**
 * Listing all player of particual user
 * method GET
 * url /player         
 */
$app->post('/player', 'authenticate', function() use ($app) {


            // check for required params
            verifyRequiredParams(array('nationality'));
            $nationality = $app->request()->post('nationality');

            $response = array();
            $db = new DbHandler();

            // fetching all user player
            $result = $db->getAllPlayer($nationality);

            $response["error"] = false;
            $response["players"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {
                echoRespnse(200, $result);
        }

    });

/**
 * Listing single poubelle of particual user
 * method GET
 * url /poubelles/:id
 * Will return 404 if the poubelle doesn't belongs to user
 */
$app->get('/poubelles/:id', 'authenticate', function($poubelle_id) {
            global $user_id;
            $response = array();
            $db = new DbHandler();

            // fetch poubelle
            $result = $db->getPoubelle($poubelle_id, $user_id);

            if ($result != NULL) {
                $response["error"] = false;
                $response["id"] = $result["id"];
                $response["sujet"] = $result["sujet"];
                $response["status"] = $result["status"];
                $response["createdAt"] = $result["created_at"];
                echoRespnse(200, $response);
            }
            else {
                $response["error"] = true;
                $response["message"] = "The requested resource doesn't exists";
                echoRespnse(404, $response);
            }
        });

/**
 * Creating new composition in db
 * method POST
 * params - name
 * url - /composition
 */
$app->post('/composition','authenticate', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('player', 'nation'));

            $response = array();
            $player = $app->request->post('player');
            $nation = $app->request->post('nation');

            global $user_id;
            $db = new DbHandler();

            // creating new composition
            $composition_id = $db->createComposition($user_id, $player, $nation);

            if ($composition_id != NULL) {
                $response["error"] = false;
                $response["message"] = "Composition created successfully";
                $response["composition_id"] = $composition_id;
                echoRespnse(201, $response);
                $res = $db->createViewCompoAdmin();
                $res2 = $db->createViewCompoNoAdmin();
            } else {
                $response["error"] = true;
                $response["message"] = "Failed to create composition. Please try again";
                echoRespnse(200, $response);
            }            
        });


/**
 * Creating new actuality in db
 * method POST
 * params - name
 * url - /actuality
 */
$app->post('/actuality','authenticate', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('content'));

            $response = array();
            $content = $app->request->post('content');
            $title = $app->request->post('content');
            global $user_id;
            $db = new DbHandler();

            if (!isset($_FILES['photo']) OR filesize($_FILES['photo']['tmp_name']) == 0 ) {

                $response["error"] = true;
                $response["message"] = 'Required field(s) ' . 'photo' . ' is missing or empty';
                echoRespnse(400, $response);
                return;
            } else {
                $photo = $_FILES['photo'];
                $logotype = $_FILES['photo']['type'];
                $logoname = $_FILES['photo']['name'];
            }


            $racine = (!empty($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . '/';
            $content_httpphoto = $racine . 'FootAPI/API/v1/ActualityPictures/';

            $content_dirphoto = __DIR__ . '/ActualityPictures/';
            $tmp_photo = $_FILES['photo']['tmp_name'];
            $taille_max = 250000;

            if (!is_uploaded_file($tmp_photo)) {
            $response["message_actuality"] = "Pas d'image";
            exit("The file is lost");
            }


             // on copie le fichier dans le dossier de destination
            $photo_file = $_FILES['photo']['name'];
            if (!move_uploaded_file($tmp_photo, $content_dirphoto . $photo_file)) {
                exit("Impossible to copy the file photo to $content_dirphoto");
            }
            $filephoto = "$content_httpphoto" . "$photo_file";

            // creating new composition
            $composition_id = $db->createActuality($user_id, $title, $content, $filephoto);

            if ($composition_id != NULL) {
                $response["error"] = false;
                $response["message"] = "Actuality created successfully";
                //$response["actuality_id"] = $actuality_id;
                echoRespnse(201, $response);
                //$res = $db->createViewCompoAdmin();
            } else {
                $response["error"] = true;
                $response["message"] = "Failed to create actuality. Please try again";
                echoRespnse(200, $response);
            }            
        });



/**
 * Listing all actuality
 * method GET
 * url /actuality         
 */
$app->get('/actuality/:id', function($user_id) use($app) {

            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllActuality($user_id);

            $response["error"] = false;
            $response["news"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {
                echoRespnse(200, $result);
        }

    });


/**
 * Creating new club in db
 * method POST
 * params - name
 * url - /club
 */
$app->post('/club', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('nom','name','email','password','role'));

            $response = array();

            //user
            $name = $app->request->post('name');
            $email = $app->request->post('email');
            $password = $app->request->post('password');
            $role = $app->request->post('role');
            $picture = NULL;

            //club
            $nom = $app->request->post('nom');
            if (!isset($_FILES['logo']) OR filesize($_FILES['logo']['tmp_name']) == 0 ) {

                $response["error"] = true;
                $response["message"] = 'Required field(s) ' . 'logo' . ' is missing or empty';
                echoRespnse(400, $response);
                return;
            } else {
                $logo = $_FILES['logo'];
                $logotype = $_FILES['logo']['type'];
                $logoname = $_FILES['logo']['name'];
            }

            if (!isset($_FILES['license']) OR filesize($_FILES['license']['tmp_name']) == 0) {
                $response["error"] = true;
                $response["message"] = 'Required field(s) ' . 'license' . ' is missing or empty';
                echoRespnse(400, $response);
                return;
            } else {
                $license = $_FILES['license'];
            }

         
        $racine = (!empty($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . '/';
        $content_httplogo = $racine . 'FootAPI/API/v1/ClubPictures/';
        $content_httplicense = $racine . 'FootAPI/API/v1/LicensePictures/';

        $content_dirlogo = __DIR__ . '/ClubPictures/';
        $content_dirlicense = __DIR__ . '/LicensePictures/';
        $tmp_logo = $_FILES['logo']['tmp_name'];
        $tmp_license = $_FILES['license']['tmp_name'];
        $taille_max = 250000;


        if (!is_uploaded_file($tmp_logo)) {
            $response["message_club"] = "Pas d'image";
            exit("The file is lost");
        }

        if (!is_uploaded_file($tmp_license)) {
            $response["message_club"] = "Pas d'image";
            exit("The file is lost");
        }

        
            // on copie le fichier dans le dossier de destination
            $logo_file = $_FILES['logo']['name'];
            $license_file = $_FILES['license']['name'];
            if (!move_uploaded_file($tmp_logo, $content_dirlogo . $logo_file)) {
                exit("Impossible to copy the file logo to $content_dirlogo");
            }
            if (!move_uploaded_file($tmp_license, $content_dirlicense . $license_file)) {
                exit("Impossible to copy the file license to $content_dirlicense");
            }
            $filelogo = "$content_httplogo" . "$logo_file";
            $filelicense = "$content_httplicense" . "$license_file";
        
            $db = new DbHandler();

            // validating email address
            //validateEmail($email);

            // creating user president
            $res = $db->createUser($name, $email, $password, $role, $picture);
            if ($res == USER_CREATED_SUCCESSFULLY) {
                $response["error"] = false;
                $response["message_user"] = "You are successfully registered";

                if ($db->checkLogin($email, $password)) {
                // get the user by email
                $users = $db->getUserByEmail($email);

                if ($users != NULL) {
                    $response["error"] = false;
                    $response['id'] = $users['id'];
                    $response['name'] = $users['name'];
                    $response['email'] = $users['email'];
                    $response['apiKey'] = $users['api_key'];
                    $response['role'] = $users['role'];
                    $response['createdAt'] = $users['created_at'];

                    // creating new club
                    $club_id = $db->createClub($response['id'], $nom, $filelogo, $filelicense);
                        if ($club_id == CLUB_CREATED_SUCCESSFULLY) {
                            $response["error"] = false;
                            $response["message_club"] = "Club created successfully";
                        } else if ($club_id == CLUB_CREATE_FAILED) {
                            $delete = $db->deleteUser($response['id']);
                            $response["error"] = true;
                            $response["message_club"] = "Oops! An error occurred while registereing";
                            $response['id'] = NULL;
                            $response['name'] = NULL;
                            $response['email'] = NULL;
                            $response['apiKey'] = NULL;
                            $response['role'] = NULL;
                            $response['createdAt'] = NULL;
                            $response["message_user"] = "An error occurred. Please try again";
                        } else if ($club_id == CLUB_ALREADY_EXISTED) {
                            $delete = $db->deleteUser($response['id']);
                            $response["error"] = true;
                            $response["message_club"] = "Sorry, this club already existed";
                            $response['id'] = NULL;
                            $response['name'] = NULL;
                            $response['email'] = NULL;
                            $response['apiKey'] = NULL;
                            $response['role'] = NULL;
                            $response['createdAt'] = NULL;
                            $response["message_user"] = "An error occurred. Please try again";
                        }  
                
                } else {
                    // unknown error occurred
                    $response['error'] = true;
                    $response['message_check_user'] = "An error occurred. Please try again";
                }
            } else {
                // user credentials are wrong
                $response['error'] = true;
                $response['message_check_user'] = 'Login failed. Incorrect credentials';
            }

            } else if ($res == USER_CREATE_FAILED) {
                $response["error"] = true;
                $response["message_user"] = "Oops! An error occurred while registereing";
            } else if ($res == USER_ALREADY_EXISTED) {
                $response["error"] = true;
                $response["message_user"] = "Sorry, this email already existed";
            }

            echoRespnse(200, $response);        
        });



/**
 * Listing all club
 * method GET
 * url /club         
 */

$app->get('/club', function() {

            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllClub();

            $response["error"] = false;
            $response["clubs"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {
                echoRespnse(200, $result);
        }

    });


/**
 * Listing all poubelles for date of particual user
 * method POST
 * url /poubelles/date         
 */
$app->post('/poubelles/date', 'authenticate', function() use ($app) {

            // check for required params
            verifyRequiredParams(array('annee'));
            $annee = $app->request->post('annee');

            global $user_id;
            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllUserPoubelleDate($user_id, $annee);

            $response["error"] = false;
            $response["poubelle"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {

            array_push($response, $result);
            echoRespnse(200, $response);
        }

        });

        

/**
 * Listing all competition
 * method GET
 * url /competition         
 */

$app->get('/competition', function() {

            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllCompetition();

            $response["error"] = false;
            $response["competitions"] = array();

            // Check to see if the final result returns false
            if($result == false) {
                $response['error'] = true;

                echoRespnse(404, $response); // echo the response of 404?

            } else {
                echoRespnse(200, $result);
        }

    });


/**
 * Updating existing poubelle
 * method PUT
 * params size
 * url - /poubelles/
 */

$app->put('/poubelles', 'authenticate', function() use($app) {
            // check for required params
            verifyRequiredParams(array('size'));

            global $user_id;            
            $size = $app->request->put('size');

            $db = new DbHandler();
            $response = array();

            // updating size
            $result = $db->updatePoubelle($user_id, $size);
            if ($result) {
                // poubelle updated successfully
                $response["error"] = false;
                $response["message"] = "Poubelle updated successfully";
            } else {
                // poubelle failed to update
                $response["error"] = true;
                $response["message"] = "Poubelle failed to update. Please try again!";
            }
            echoRespnse(200, $response);
        });
    

/**
 * Deleting poubelle. Users can delete only their poubelles
 * method DELETE
 * url /poubelle
 */
$app->delete('/poubelles/:id', 'authenticate', function($poubelle_id) use($app) {
            global $user_id;

            $db = new DbHandler();
            $response = array();
            $result = $db->deletePoubelle($user_id, $poubelle_id);
            if ($result) {
                // poubelle deleted successfully
                $response["error"] = false;
                $response["message"] = "Poubelle deleted succesfully";
            } else {
                // poubelle failed to delete
                $response["error"] = true;
                $response["message"] = "Poubelle failed to delete. Please try again!";
            }
            echoRespnse(200, $response);
        });

/**
 * Verifying required params posted or not
 */
function verifyRequiredParams($required_fields) {
    $error = false;
    $error_fields = "";
    $request_params = array();
    $request_params = $_REQUEST;
    // Handling PUT request params
    if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
        $app = \Slim\Slim::getInstance();
        parse_str($app->request()->getBody(), $request_params);
    }
    foreach ($required_fields as $field) {
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= 0) {
            $error = true;
            $error_fields .= $field . ', ';
        }
    }

    if ($error) {
        // Required field(s) are missing or empty
        // echo error json and stop the app
        $response = array();
        $app = \Slim\Slim::getInstance();
        $response["error"] = true;
        $response["message"] = 'Required field(s) ' . substr($error_fields, 0, -2) . ' is missing or empty';
        echoRespnse(400, $response);
        $app->stop();
    }
}



/**
 * Validating email address
 */
function validateEmail($email) {
    $app = \Slim\Slim::getInstance();
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $response["error"] = true;
        $response["message"] = 'Email address is not valid';
        echoRespnse(400, $response);
        $app->stop();
    }
}

/**
 * Echoing json response to client
 * @param String $status_code Http response code
 * @param Int $response Json response
 */
function echoRespnse($status_code, $response) {
    $app = \Slim\Slim::getInstance();
    // Http response code
    $app->status($status_code);

    // setting response content type to json
    $app->contentType('application/json');

    echo json_encode($response);
}

$app->run();
?>