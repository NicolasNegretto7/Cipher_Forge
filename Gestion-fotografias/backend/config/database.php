class database{

    private $host = 'db';
    private $name = 'cipher_forge';
    private $user = 'cipher_user';
    private $password = 'cipher_password';
    private $port = '3306';

    $dsn = "mysql:host=$host;port=$port;dbname=$name";

    public function __construct(){
        try {
            $this->con = new PDO($dsn, $this->user, $this->password);
            $this->con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            throw new PDOException($e->getMessage());
        }
    }
}