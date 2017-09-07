<?php

require_once '../include/DbHandler.php';
require_once '../include/PassHash.php';
require '.././libs/Slim/Slim.php';

\Slim\Slim::registerAutoloader();

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
            verifyRequiredParams(array('name', 'email', 'password'));

            $response = array();

            // reading post params
            $name = $app->request->post('name');
            $email = $app->request->post('email');
            $password = $app->request->post('password');

            // validating email address
            validateEmail($email);

            $db = new DbHandler();
            $res = $db->createUser($name, $email, $password);

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
 * Listing all poubelles of particual user
 * method GET
 * url /poubelles         
 */
$app->get('/poubelles', 'authenticate', function() {
            global $user_id;
            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllUserPoubelle($user_id);

            $response["error"] = false;
            $response["poubelle"] = array();

            // looping through result and preparing poubelle array
            while ($poubelle = $result->fetch_assoc()) {
                $tmp = array();
                $tmp["id"] = $poubelle["id"];
                $tmp["sujet"] = $poubelle["sujet"];
                $tmp["status"] = $poubelle["status"];
                $tmp["size"] = $poubelle["size"];
                $tmp["createdAt"] = $poubelle["created_at"];
                array_push($response["poubelle"], $tmp);
            }

            echoRespnse(200, $response);
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
 * Creating new poubelle in db
 * method POST
 * params - name
 * url - /poubelles/
 */
$app->post('/poubelles','authenticate', function() use ($app) {
            // check for required params
            verifyRequiredParams(array('sujet'));

            $response = array();
            $sujet = $app->request->post('sujet');

            global $user_id;
            $db = new DbHandler();

            // creating new poubelle
            $poubelle_id = $db->createPoubelle($user_id, $sujet);

            if ($poubelle_id != NULL) {
                $response["error"] = false;
                $response["message"] = "Poubelle created successfully";
                $response["poubelle_id"] = $poubelle_id;
                echoRespnse(201, $response);
            } else {
                $response["error"] = true;
                $response["message"] = "Failed to create poubelle. Please try again";
                echoRespnse(200, $response);
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
 * Listing size for last user id
 * method POST
 * url /poubelles/size         
 */

$app->post('/poubelles/size', 'authenticate', function() use ($app) {

            // check for required params
            verifyRequiredParams(array('annee'));
            $annee = $app->request->post('annee');

            global $user_id;
            $response = array();
            $db = new DbHandler();

            // fetching all user poubelles
            $result = $db->getAllUserPoubelleSize($user_id, $annee);

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
 * Updating all existing poubelle in 0
 * method PUT
 * params size
 * url - /clearpoubelles/:id
 */
/*
$app->put('/clearpoubelles', 'authenticate', function() use($app) {
            // check for required params
            //verifyRequiredParams(array('size'));

            global $user_id;            
            $size = $app->request->put('size');

            $db = new DbHandler();
            $response = array();

            // updating size
            $result = $db->updateClearPoubelle();
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
*/

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