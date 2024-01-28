#Rename the columns

alter table new_schema.dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
rename column `Kod wojewdztwa` to Kod_wojewdztwa,
rename column `Kod powiatu` to Kod_powiatu,
rename column `Kod gminy` to Kod_gminy,
rename column `Typ gminy` to Typ_gminy,
rename column `Nazwa formularza` to Nazwa_formularza,
rename column `Liczba podatnikw` to Liczba_podatnikw,
rename column `Kwota przychodu                   w tys zotych` to Kwota_przychodu_w_tys_zotych,
rename column `Kwota dochodu w tys zotych` to Kwota_dochodu_w_tys_zotych,
rename column `Kwota dochodu do opodatkowania                  w tys zotych` to Kwota_dochodu_do_opodatkowania_w_tys_zotych,
rename column `Podatek naleny                  w tys zotych` to Podatek_naleny_w_tys_zotych,
rename column `Liczba podatnikw` to Liczba_podatnikw;

#Sum of people paying taxes & total tax paid in 2022

SELECT
    SUM(CASE WHEN Nazwa_formularza = 'Pit37' THEN Liczba_podatnikw ELSE 0 END) AS Wszyscy_podatnicy,
    SUM(Podatek_naleny_w_tys_zotych) AS Podatek_w_tys_zl,
    SUM(CASE WHEN Nazwa_formularza = 'Pit37' THEN Podatek_naleny_w_tys_zotych ELSE 0 END) AS Podatek_z_pit_37_w_tys_zl
FROM dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok;

#Total tax from Pit paid in 2022

select
	sum(Podatek_naleny_w_tys_zotych) as Podatek_w_tys_zl
from dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok;

#Aggregate the number of people paying taxes and amount of tax paid by County (Pit-37 only)

select 
	Powiat,
    sum(Liczba_podatnikw) as Wszyscy_podatnicy,
    sum(Podatek_naleny_w_tys_zotych) as Podatek_w_tys_zl,
    (sum(Podatek_naleny_w_tys_zotych)/sum(Liczba_podatnikw))*1000 as avg_podatek
from new_schema.dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
where Nazwa_formularza = 'Pit37'
Group by Powiat
Order by avg_podatek desc;

#Aggregate the number of people paying taxes and amount of tax paid by Tax Form type

select 
	Nazwa_formularza,
    sum(Liczba_podatnikw) as Wszyscy_podatnicy,
    sum(Podatek_naleny_w_tys_zotych) as Podatek_w_tys_zl,
    (sum(Podatek_naleny_w_tys_zotych)/sum(Liczba_podatnikw))*1000 as avg_podatek
from new_schema.dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
Group by Nazwa_formularza
Order by Wszyscy_podatnicy desc;

#Aggregate the number of people paying taxes and amount of tax paid by Commune type (GM = City, GW = Villages, MW = Commune with Cities and Villages)

select 
	Typ_gminy,
    sum(Liczba_podatnikw) as Wszyscy_podatnicy,
    sum(Podatek_naleny_w_tys_zotych) as Podatek_w_tys_zl,
    (sum(Podatek_naleny_w_tys_zotych)/sum(Liczba_podatnikw))*1000 as avg_podatek
from dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
where Nazwa_formularza = 'Pit37'
Group by Typ_gminy;

#Check the rates for the above

select 
	Typ_gminy,
    sum(Liczba_podatnikw) as Wszyscy_podatnicy,
    (sum(Liczba_podatnikw)/(select sum(Liczba_podatnikw) from dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok where Nazwa_formularza = 'Pit37'))*100 as proc_podatnikow, 
	sum(Podatek_naleny_w_tys_zotych) as Podatek_w_tys_zl,
    (sum(Podatek_naleny_w_tys_zotych)/(select sum(Podatek_naleny_w_tys_zotych) from dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok where Nazwa_formularza = 'Pit37'))*100 as proc_podatku
from dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
where Nazwa_formularza = 'Pit37'
Group by Typ_gminy;

#effective taxation rate

SELECT
    Nazwa_formularza,
    SUM(Kwota_przychodu_w_tys_zotych) AS Suma_przychodu,
    SUM(Kwota_dochodu_w_tys_zotych) AS Suma_dochodu,
    SUM(Kwota_dochodu_do_opodatkowania_w_tys_zotych) AS Suma_dochodu_do_opodatkowania,
    SUM(Podatek_naleny_w_tys_zotych) AS Suma_podatku,
    ifnull(SUM(Podatek_naleny_w_tys_zotych)/SUM(Kwota_dochodu_do_opodatkowania_w_tys_zotych)*100, SUM(Podatek_naleny_w_tys_zotych)/SUM(Kwota_przychodu_w_tys_zotych)*100) as Tax_rate
FROM dane_z_rozliczenia_pit_w_ukladzie_terytorialnym_za_2022_rok
GROUP BY Nazwa_formularza
order by Tax_rate desc;









