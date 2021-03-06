Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

Link to case stusy : https://8weeksqlchallenge.com/case-study-6/

2. Digital Analysis

1.How many users are there?
select count(distinct user_id) from clique_bait.users

2.How many cookies does each user have on average?
select user_id, count(cookie_id)
from clique_bait.users
group by user_id
order by count(cookie_id) desc

3.What is the unique number of visits by all users per month?
select count(distinct user_id), extract(month from start_date) as month
from clique_bait.users
group by month

4.What is the number of events for each event type?
select event_type, count(event_name)
from clique_bait.event_identifier
group by event_type

5.What is the percentage of visits which have a purchase event?
with perc as 
    (select visit_id, e.event_type, event_name 
    from clique_bait.events e
    join clique_bait.event_identifier ei
    on e.event_type = ei.event_type 
    )

select round(((cast(count(visit_id) as numeric))/(select count(*) from perc))*100,2) as p
from perc
where event_name = 'Purchase'

6.What is the percentage of visits which view the checkout page but do not have a purchase event?
select visit_id, event_name, page_name
from clique_bait.events e 
join clique_bait.page_hierarchy ph 
on e.page_id = ph.page_id
join clique_bait.event_identifier ei
on e.event_type = ei.event_type
where page_name = 'Checkout' and event_name = 'Purchase'

7. What are the top 3 pages by number of views?
select page_name, count(visit_id) as cnt
from clique_bait.events e 
join clique_bait.page_hierarchy ph 
on e.page_id = ph.page_id
group by page_name
order by cnt desc
LIMIT 3

8.What is the number of views and cart adds for each product category?
select t1.product_category, no_of_views, cart_adds
from
    (select product_category, count(visit_id)  as no_of_views
    from clique_bait.events e 
    join clique_bait.page_hierarchy ph 
    on e.page_id = ph.page_id
    join clique_bait.event_identifier ei 
    on e.event_type = ei.event_type
    where product_category is not null
    group by product_category) t1 
join 
    (select product_category, count(event_name) as cart_adds
    from clique_bait.events e 
    join clique_bait.page_hierarchy ph 
    on e.page_id = ph.page_id
    join clique_bait.event_identifier ei 
    on e.event_type = ei.event_type
    where product_category is not null and event_name = 'Add to Cart'
    group by product_category) t2
on t1.product_category = t2.product_category 

9. What are the top 3 products by purchases?
with prod_ident as 
( 
  select visit_id, sequence_number, page_name, event_name 
  from clique_bait.events e
  join clique_bait.page_hierarchy ph 
  on e.page_id = ph.page_id 
  join clique_bait.event_identifier ei
  on e.event_type = ei.event_type
  order by visit_id, sequence_number
)

select page_name, count(page_name) as Purchase_cnt
from prod_ident
where visit_id IN (select visit_id
                  from prod_ident
                  where event_name = 'Purchase'
                  order by visit_id, sequence_number) and 
      page_name not in ('Checkout', 'Confirmation', 'Home Page', 						'All Products')
group by page_name 
order by Purchase_cnt desc 
limit 3




