<?php

/**
 * Class to handle all db operations
 * This class will have CRUD methods for database tables
 *
 * @author Sedraia Tayeb
 * @link URL Tutorial link
 */
class DbHandler {

    private $conn;

    function __construct() {
        require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();
    }

    /* ------------- `users` table method ------------------ */

    /**
     * Creating new user
     * @param String $name User full name
     * @param String $email User login email id
     * @param String $password User login password
     */
    public function createUser($name, $email, $password) {
        require_once 'PassHash.php';
        $response = array();

        // First check if user already existed in db
        if (!$this->isUserExists($email)) {
            // Generating password hash
            $password_hash = PassHash::hash($password);

            // Generating API key
            $api_key = $this->generateApiKey();

            // insert query
            $stmt = $this->conn->prepare("INSERT INTO users(name, email, password_hash, api_key, role) values(?, ?, ?, ?, 0)");
            $stmt->bind_param("ssss", $name, $email, $password_hash, $api_key);

            $result = $stmt->execute();

            $stmt->close();

            // Check for successful insertion
            if ($result) {
                // User successfully inserted
                return USER_CREATED_SUCCESSFULLY;
            } else {
                // Failed to create user
                return USER_CREATE_FAILED;
            }
        } else {
            // User with same email already existed in the db
            return USER_ALREADY_EXISTED;
        }

        return $response;
    }

    /**
     * Checking user login
     * @param String $email User login email id
     * @param String $password User login password
     * @return boolean User login status success/fail
     */
    public function checkLogin($email, $password) {
        // fetching user by email
        $stmt = $this->conn->prepare("SELECT password_hash FROM users WHERE email = ?");

        $stmt->bind_param("s", $email);

        $stmt->execute();

        $stmt->bind_result($password_hash);

        $stmt->store_result();

        if ($stmt->num_rows > 0) {
            // Found user with the email
            // Now verify the password

            $stmt->fetch();

            $stmt->close();

            if (PassHash::check_password($password_hash, $password)) {
                // User password is correct
                return TRUE;
            } else {
                // user password is incorrect
                return FALSE;
            }
        } else {
            $stmt->close();

            // user not existed with the email
            return FALSE;
        }
    }

    /**
     * Checking for duplicate user by email address
     * @param String $email email to check in db
     * @return boolean
     */
    private function isUserExists($email) {
        $stmt = $this->conn->prepare("SELECT id from users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $stmt->store_result();
        $num_rows = $stmt->num_rows;
        $stmt->close();
        return $num_rows > 0;
    }

    /**
     * Fetching user by email
     * @param String $email User email id
     */
    public function getUserByEmail($email) {
        $stmt = $this->conn->prepare("SELECT name, email, api_key, role, created_at FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        if ($stmt->execute()) {
            // $user = $stmt->get_result()->fetch_assoc();
            $stmt->bind_result($name, $email, $api_key, $role, $created_at);
            $stmt->fetch();
            $user = array();
            $user["name"] = $name;
            $user["email"] = $email;
            $user["api_key"] = $api_key;
            $user["role"] = $role;
            $user["created_at"] = $created_at;
            $stmt->close();
            return $user;
        } else {
            return NULL;
        }
    }

    /**
     * Fetching user api key
     * @param String $user_id user id primary key in user table
     */
    public function getApiKeyById($user_id) {
        $stmt = $this->conn->prepare("SELECT api_key FROM users WHERE id = ?");
        $stmt->bind_param("i", $user_id);
        if ($stmt->execute()) {
            // $api_key = $stmt->get_result()->fetch_assoc();
            // TODO
            $stmt->bind_result($api_key);
            $stmt->close();
            return $api_key;
        } else {
            return NULL;
        }
    }

    /**
     * Fetching user id by api key
     * @param String $api_key user api key
     */
    public function getUserId($api_key) {
        $stmt = $this->conn->prepare("SELECT id FROM users WHERE api_key = ?");
        $stmt->bind_param("s", $api_key);
        if ($stmt->execute()) {
            $stmt->bind_result($user_id);
            $stmt->fetch();
            // TODO
            // $user_id = $stmt->get_result()->fetch_assoc();
            $stmt->close();
            return $user_id;
        } else {
            return NULL;
        }
    }

    /**
     * Validating user api key
     * If the api key is there in db, it is a valid key
     * @param String $api_key user api key
     * @return boolean
     */
    public function isValidApiKey($api_key) {
        $stmt = $this->conn->prepare("SELECT id from users WHERE api_key = ?");
        $stmt->bind_param("s", $api_key);
        $stmt->execute();
        $stmt->store_result();
        $num_rows = $stmt->num_rows;
        $stmt->close();
        return $num_rows > 0;
    }

    /**
     * Generating random Unique MD5 String for user Api key
     */
    private function generateApiKey() {
        return md5(uniqid(rand(), true));
    }

    /**
     * Fetching all user score
     * @param String $user_id id of the user
     */
    public function getAllUserScore() {
        $stmt = $this->conn->prepare("SELECT id,name,email,score FROM users ORDER BY score DESC");
        $stmt->execute();
        $composition = $stmt->get_result();
        $stmt->close();
        return $composition;
    }


    /**
     * Updating score user
     * @param String $user_id id of the user
     * @param String $score score integer
     */
    public function updateUserScore($user_id, $score) {
        var_dump($user_id);
        var_dump($score);
        $stmt = $this->conn->prepare("UPDATE users SET score = ? where id=? AND role != 'admin' ");
        $stmt->bind_param("ii", $score, $user_id);
        $stmt->execute();
        $num_affected_rows = $stmt->affected_rows;
        $stmt->close();
        return $num_affected_rows > 0;
    }

    /* ------------- `composition` table method ------------------ */

    /**
     * Creating new composition
     * @param String $user_id user id to whom player belongs to
     * @param String $player player text
     */
    public function createComposition($user_id, $player,$nation) {
        $stmt = $this->conn->prepare("INSERT INTO composition(player,nation) VALUES(?,?)");
        $stmt->bind_param("ss", $player,$nation);
        $result = $stmt->execute();
        $stmt->close();

        if ($result) {
            // composition row created
            // now assign the composition to user
            $new_composition_id = $this->conn->insert_id;
            $res = $this->createUserComposition($user_id, $new_composition_id);
            if ($res) {
                // composition created successfully
                return $new_composition_id;
            } else {
                // composition failed to create
                return NULL;
            }
        } else {
            // composition failed to create
            return NULL;
        }
    }

    /**
     * Fetching single poubelle
     * @param String $poubelle_id id of the poubelle
     */
    public function getPoubelle($poubelle_id, $user_id) {
        $stmt = $this->conn->prepare("SELECT t.id, t.sujet, t.status, t.created_at from poubelle t, user_poubelle ut WHERE t.id = ? AND ut.poubelle_id = t.id AND ut.user_id = ?");
        $stmt->bind_param("ii", $poubelle_id, $user_id);
        if ($stmt->execute()) {
            $res = array();
            $stmt->bind_result($id, $sujet, $status, $created_at);
            // TODO
 
            $stmt->fetch();
            $res["id"] = $id;
            $res["sujet"] = $sujet;
            $res["status"] = $status;
            $res["created_at"] = $created_at;
            $stmt->close();
            return $res;
        } else {
            return NULL;
        }
    }

    /**
     * Fetching all user composition
     * @param String $user_id id of the user
     */
    public function getAllUserComposition($user_id) {
        $stmt = $this->conn->prepare("SELECT c.* FROM composition c, user_composition uc WHERE c.id = uc.composition_id AND uc.user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $composition = $stmt->get_result();
        $stmt->close();
        return $composition;
    }


    /**
     * Fetching all user composition
     * @param String $user_id id of the user
     */
    public function getResultComposition() {
        $stmt = $this->conn->prepare("SELECT * FROM touslesjoueursnoadmin noadmin WHERE EXISTS(SELECT * FROM touslesjoueursadmin c2 
            WHERE c2.nation = noadmin.nation AND c2.player = noadmin.player)");
        //$stmt->bind_param("i", $user_id);

        $stmt->execute();
        $composition = $stmt->get_result();
        var_dump($composition)
        $stmt->close();
        return $composition;
    }

            /**
     * Create view composition no admin
     * @param no param
     */
    public function createViewCompoNoAdmin() {
        $stmt = $this->conn->prepare("CREATE OR REPLACE VIEW touslesjoueursnoadmin AS
        SELECT c.*, u.api_key
        FROM composition c, user_composition uc, users u
        WHERE c.id = uc.composition_id
        AND u.id =  uc.user_id
        AND uc.user_id != 1");
        //$stmt->bind_param("i", $user_id);
  
        //$stmt->bind_param("s", $nationality);
        $stmt->execute();
        $composition = $stmt->get_result();
        $stmt->close();
        return $composition;
    }

    /**
     * Create view composition admin
     * @param no param
     */
    public function createViewCompoAdmin() {
        $stmt = $this->conn->prepare("CREATE OR REPLACE VIEW touslesjoueursadmin AS
        SELECT c.* 
        FROM composition c, user_composition uc 
        WHERE c.id = uc.composition_id AND uc.user_id = 1");
        //$stmt->bind_param("i", $user_id);
  
        //$stmt->bind_param("s", $nationality);
        $stmt->execute();
        $composition = $stmt->get_result();
        $stmt->close();
        return $composition;
    }

        /**
     * Fetching all user composition
     * @param String $user_id id of the user
     */
    public function getAllPlayer($nationality) {
        $stmt = $this->conn->prepare("SELECT * FROM player WHERE Rating > 78 AND Nationality = ?");
        //$stmt->bind_param("i", $user_id);
  
        $stmt->bind_param("s", $nationality);
        $stmt->execute();
        $composition = $stmt->get_result();
        $stmt->close();
        return $composition;
    }

        /**
     * Fetching all user poubelles for date
     * @param String $user_id id of the user
     */
    public function getAllUserPoubelleDate($user_id, $annee) {
        $stmt = $this->conn->prepare("SELECT MAX(p.id), p.created_at, p.size, MONTH(p.created_at) AS mois, YEAR(p.created_at) AS annee, COUNT( * ) AS nombre  FROM poubelle p, user_poubelle up WHERE p.id = up.poubelle_id AND up.user_id = ? AND YEAR(p.created_at) = ? GROUP BY annee, mois");
        $stmt->bind_param("ii", $user_id, $annee);
         if ($stmt->execute()) {
            $res = array();
            $stmt->store_result();
            $stmt->bind_result($id, $created_at, $size, $mois, $annee, $nombre);
            // TODO
 
            while($stmt->fetch())
            {           
                $temp = array();
                $temp["id"] = $id;
                $temp["created_at"] = $created_at;
                $temp["size"] = $size;
                $temp["mois"] = $mois;
                $temp["annee"] = $annee;
                $temp["nombre"] = $nombre;
                
                array_push($res, $temp);
            }

            $stmt->close();
            return $res;
        } else {
            return NULL;
        }
    }


            /**
     * Fetching size for the last id
     * @param String $user_id id of the user
     */
    public function getAllUserPoubelleSize($user_id, $annee) {
        $stmt = $this->conn->prepare("SELECT MAX(p.id), p.created_at, p.size, MONTH(p.created_at) AS mois, YEAR(p.created_at) AS annee, COUNT( * ) AS nombre  FROM poubelle p, user_poubelle up WHERE p.id = up.poubelle_id AND up.user_id = ? AND YEAR(p.created_at) = ? GROUP BY size");
        $stmt->bind_param("ii", $user_id, $annee);
         if ($stmt->execute()) {
            $res = array();
            $stmt->store_result();
            $stmt->bind_result($id, $created_at, $size, $mois, $annee, $nombre);
            // TODO
 
            while($stmt->fetch())
            {           
                $temp = array();
                $temp["id"] = $id;
                $temp["created_at"] = $created_at;
                $temp["size"] = $size;
                $temp["mois"] = $mois;
                $temp["annee"] = $annee;
                $temp["nombre"] = $nombre;
                
                array_push($res, $temp);
            }

            $stmt->close();
            return $res;
        } else {
            return NULL;
        }
    }


    /**
     * Updating all size poubelle in 0
     * @param String $poubelle_id id of the poubelle
     * @param String $size size integer
     */
    public function updateClearPoubelle() {
        $stmt = $this->conn->prepare(
        "UPDATE poubelle set size = 0;");
        

        //$stmt->bind_param("i", $user_id);
        $stmt->execute();
        $num_affected_rows = $stmt->affected_rows;
        $stmt->close();
        return $num_affected_rows > 0;
    }

    /**
     * Updating poubelle
     * @param String $poubelle_id id of the poubelle
     * @param String $size size integer
     */
    public function updatePoubelle($user_id, $size) {
        $this->updateClearPoubelle();
        
        $stmt = $this->conn->prepare(
        "UPDATE poubelle p
        JOIN ( 
            SELECT * , MAX(poubelle_id) AS maxID
            FROM user_poubelle up
            WHERE up.user_id = ?
            AND MONTH(created_at)=MONTH(now())) AS up 
        ON p.id = maxID
        SET size = ?");
        

        $stmt->bind_param("ii", $user_id, $size);
        $stmt->execute();
        $num_affected_rows = $stmt->affected_rows;
        $stmt->close();
        return $num_affected_rows > 0;
    }

    

    /**
     * Deleting a poubelle
     * @param String $poubelle_id id of the poubelle to delete
     */
    public function deletePoubelle($user_id, $poubelle_id) {
        $stmt = $this->conn->prepare("DELETE t FROM poubelle t, user_poubelle ut WHERE t.id = ? AND ut.poubelle_id = t.id AND ut.user_id = ?");
        $stmt->bind_param("ii", $poubelle_id, $user_id);
        $stmt->execute();
        $num_affected_rows = $stmt->affected_rows;
        $stmt->close();
        return $num_affected_rows > 0;
    }

    /* ------------- `user_composition` table method ------------------ */

    /**
     * Function to assign a composition to user
     * @param String $user_id id of the user
     * @param String $composition_id id of the composition
     */
    public function createUserComposition($user_id, $composition_id) {
        $stmt = $this->conn->prepare("INSERT INTO user_composition(user_id, composition_id) values(?, ?)");
        $stmt->bind_param("ii", $user_id, $composition_id);
        $result = $stmt->execute();

        if (false === $result) {
            die('execute() failed: ' . htmlspecialchars($stmt->error));
        }
        $stmt->close();
        return $result;
    }

    /* ------------- `player` table method ------------------ */

    /**
     * ImportCSV in table player
     * @param String $Name name
     * @param String $Nationality Nationality text
     * @param String $Club text
     */

    public function importPlayerCSV($Name, $Nationality, $National_Position, $Club, $Club_Position, $Club_Joining, $Contract_Expiry, $Rating, $Age) {

        $stmt = $this->conn->prepare("INSERT INTO player(Name, Nationality, National_Position, Club, Club_Position, Club_Joining, Contract_Expiry, Rating, Age) VALUES(?,?,?,?,?,?,?,?,?)");
        $stmt->bind_param("sssssssss", $Name, $Nationality, $National_Position, $Club, $Club_Position, $Club_Joining, $Contract_Expiry, $Rating, $Age);
        $result = $stmt->execute();
        $stmt->close();
        return $result;

    }


}

?>
