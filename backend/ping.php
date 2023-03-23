<? php $str = exec("ping -c 1 https://dndbackend.onrender.com"); if ($result == 0){ echo "ping succeeded"; }else{ echo "ping failed"; } ?>
