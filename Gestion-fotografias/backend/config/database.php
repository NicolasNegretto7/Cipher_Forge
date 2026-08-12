class database{

    private $host = db;
    private $name = cipher_forge;
    private $user = cipher_user;
    private $password = cipher_password;
    private $port = 3306;

    public function __construct(){
        try {
            $this->con = new PDO("mysql:host=$this->host;port=$this->port;dbname=$this->name", $this->user, $this->password);
            $this->con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            throw new PDOException($e->getMessage());
        }
    }
}