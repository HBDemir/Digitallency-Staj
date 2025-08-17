SELECT 
    country AS ulke_adi, --her ülkedeki müşteri sayısını hesaplarız
    COUNT(customer_id) AS musteri_sayisi
FROM customer
GROUP BY country --kayıtları ülkelere göre gruplarız
ORDER BY musteri_sayisi DESC; --sonuçları müşteri sayısına göre büyükten küçüğe sıralarız



SELECT 
    ar.name AS sanatci_adi,
    COUNT(al.album_id) AS album_sayisi --her sanatçının albüm sayısını hesaplarız
FROM artist ar
INNER JOIN album al ON ar.artist_id = al.artist_id --artist ve album tablolarını artist_id üzerinden birleştiririz
GROUP BY ar.artist_id, ar.name --kayıtları sanatçılara göre gruplarız
ORDER BY album_sayisi DESC; --sonuçları albüm sayısına göre azalan şekilde sıralarız

SELECT 
    t.name AS parca_adi,
    t.milliseconds AS sure_ms,
    al.title AS album_adi,
    ar.name AS sanatci_adi
FROM track t
INNER JOIN album al ON t.album_id = al.album_id
INNER JOIN artist ar ON al.artist_id = ar.artist_id --track, album ve artist tablolarını birleştiririz
ORDER BY t.milliseconds DESC --parçaları süre uzunluğuna göre büyükten küçüğe sıralarız
LIMIT 10;--En uzun 10 parçayı albüm ve sanatçı bilgileriyle birlikte görürüz

