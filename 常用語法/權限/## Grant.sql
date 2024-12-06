--如果對方有datareader的權限，卻還是看不見procedure，執行以下語法
GRANT VIEW DEFINITION TO hx

--給 user 在某一張表的 alter 權限
Grant alter on merchant_archive to fs_egame_user

--給 hx EXECUTE的權限
GRANT EXECUTE TO hx

--給 hx 執行某一支procedure的權限
GRANT EXECUTE ON procedure_name TO hx;
