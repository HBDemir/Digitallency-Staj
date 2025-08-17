SELECT 
    al.title AS album_adi,
    AVG(t.milliseconds) AS ortalama_sure_ms, --her albümün parçalarının ortalama süresini hesaplarız
    --ROUND(AVG(t.milliseconds), 2) AS ortalama_sure_yuvarlanmis (opsiyonel)
FROM album al
INNER JOIN track t ON al.album_id = t.album_id --album ve track tablolarını album_id üzerinden birleştiririz
GROUP BY al.album_id, al.title -- kayıtları albümlere göre gruplarız
ORDER BY ortalama_sure_ms DESC; -- ortalama süreye göre azalan sırada sıralarız albümleri

SELECT 
    al.title AS album_adi,
    t.name AS en_uzun_parca,
    t.milliseconds AS en_uzun_sure_ms
FROM album al
INNER JOIN track t ON al.album_id = t.album_id -- track ve albüm tablolarını album_id üzerinden birleştiririz
WHERE t.milliseconds = (
--subquery kullanarak hem parça adını hem de süresini gösteririz
--bir albümün en uzun parçasını alır bu subquery
    SELECT MAX(t2.milliseconds) --albümün en uzun parça süresini buluruz
    FROM track t2
    WHERE t2.album_id = al.album_id
)
ORDER BY t.milliseconds DESC; --süreye göre azalan şekilde sıralar


SELECT 
    t.name AS parca_adi,
    t.unit_price AS fiyat,
    al.title AS album_adi,
    ar.name AS sanatci_adi
FROM track t
INNER JOIN album al ON t.album_id = al.album_id
INNER JOIN artist ar ON al.artist_id = ar.artist_id --track, album ve artist tablolarını birleştiririz
ORDER BY t.unit_price DESC --fiyatlarına göre azalan şekilde sıralarız
LIMIT 5; --sadece ilk 5 kaydı alırız