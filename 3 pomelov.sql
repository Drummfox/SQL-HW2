--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat( c.first_name, ' ', c.last_name), a.address, ci.city, c2.country 
from customer c 
join address a on c.address_id = a.address_id 
join city ci on a.city_id = ci.city_id 
join country c2 on ci.country_id = c2.country_id 



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select s.store_id, count(c.customer_id) as "quantity customers"
from store s
join customer c ON s.store_id = c.store_id 
group by s.store_id



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select s.store_id, count(c.customer_id)
	from store s
	join customer c ON s.store_id = c.store_id 
	group by 1
	having count(c.customer_id) > 300



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.


select t.store_id, t.q_customers, c2.city, concat(s2.last_name, ' ', s2.first_name)
from(
	select s.store_id, s.address_id, count(c.customer_id) as q_customers
	from store s
	join customer c ON s.store_id = c.store_id  
	group by 1
	having count(c.customer_id) > 300) t
join address a on t.address_id = a.address_id 
join city c2 on a.city_id = c2.city_id
join staff s2 on t.store_id  = s2.store_id 


select
  nt.store_id as "ID",
  nt.cust as "кол-во клиентов",
  c.city as "Город",
  concat(s.last_name, ' ', s.first_name) as "Продавец"
from
  city c 
inner join
  address a 
on
  c.city_id = a.city_id 
inner join 
  staff s 
on
  a.address_id = s.address_id 
inner join 
  (select 
     store_id, 
     count(customer_id) as cust
   from
     customer 
   group by
     store_id
   having 
     count(customer_id) > 300) as nt on nt.store_id = s.store_id

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select 	concat (c.first_name, ' ', c.last_name), t.q_rent
from 
	(select r.customer_id, count(rental_id) as q_rent
	from rental r 
	group by 1
	order by q_rent desc 
	limit 5) t
join customer c on t.customer_id = c.customer_id 
order by 2 desc 



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма


select concat (c.first_name, ' ', c.last_name) as "Фамилия и имя покупателя", t.r_sum "Количество фильмов", 
t.a_sum "Общая стоимость платежей", t.a_min "Минимальная стоимость платежа", t.a_max  "Максимальная стоимость платежа"
from 
	(select 
	p.customer_id,
	count(p.rental_id) as r_sum,
	round( sum(p.amount), 0) as a_sum,
	min(p.amount) as a_min,
	max(p.amount) as a_max
	from payment p 
	group by 1) t
join customer c on t.customer_id = c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 

select c.city, c2.city 
from city c 
cross join city c2
where c.city <>c2.city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select r.customer_id, round(avg(return_date::date-rental_date::date),2)
from rental r 
group by 1
order by 1



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f2.title, f2.rating, f2.release_year, count(r.rental_id), sum(p.amount)
			from rental r
			join inventory i on r.inventory_id  = i.inventory_id 
			join film f2 on i.film_id = f2.film_id
			join payment p on r.rental_id = p.rental_id 
			group by f2.film_id 



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select f.title, f.rating, f.release_year, count(r.rental_id), sum(p.amount)
			from film f
			left join inventory i on f.film_id  = i.film_id 
			left join rental r  on i.inventory_id = r.inventory_id 
			left join payment p on r.rental_id = p.rental_id 
			group by f.film_id 
			having count(r.rental_id) = 0



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select p.staff_id, count (p.payment_id),
		case 
			when count (p.payment_id)>8000 then 'Yes'
			else 'No'
		end
from payment p
group by p.staff_id 





