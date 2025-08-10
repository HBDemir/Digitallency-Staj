-- 1. Invoice tablosunda, tüm değerleri NULL olan kayıtların sayısını bulma
SELECT COUNT(*) 
FROM invoice 
WHERE invoice_id IS NULL 
  AND customer_id IS NULL 
  AND invoice_date IS NULL 
  AND billing_address IS NULL 
  AND billing_city IS NULL 
  AND billing_state IS NULL 
  AND billing_country IS NULL 
  AND billingpostal_code IS NULL 
  AND total IS NULL;
-- Row sayısı: 0  (0 çıkması normal tablolar yaratılırken not  null constranti kullanılmış
-- bu nedenle tüm satırın null olduğu bir girdi yok)
-- bu sorguda and operatörü ile eş zamanlı olarak gerçekleşmesi gerekn durumları kontrol ediyoruz
-- IS NULL eğer o columndaki o satırın değeri null ise true döndürür.

-- 2. Total değerlerinin iki katını gösterme ve karşılaştırma (küçükten büyüğe sıralama)
SELECT 
    invoice_id, 
    customer_id,
    invoice_date,
    total AS old_total,
    (total * 2) AS new_total -- totalin 2 katını yeni bir column olarak gösteriyoruz
FROM invoice
WHERE total IS NOT NULL -- total değer null ise 2 katıda var olamaz hata almamak için ekledim
ORDER BY new_total ASC; -- new_totale göre verileri artan sırada sıralıyoruz.(küçükten büyüğe)

-- 3. Adres kolonundan sol 3 ve sağ 4 karakter alarak birleştirme (2013 yılı 10. ay filtresi)
SELECT 
    invoice_id,
    customer_id,
    billing_address,
    CONCAT(LEFT(billing_address, 3), RIGHT(billing_address, 4)) AS "Açık Adres", 
    invoice_date
FROM invoice
WHERE EXTRACT(YEAR FROM invoice_date) = 2013 
  AND EXTRACT(MONTH FROM invoice_date) = 10;
-- extract fonksiyonu içine verdiğimiz tarihten istediğimiz kısmını almamızı sağlıyor
-- biling_address in left fonksiyonu ile soldan ilk 3 elemanını alıyoruz 
-- right fonksiyonu ile sağdan 4 elemanını alıyoruz
-- concat ile bu iki stringi birleştiriyoruz
