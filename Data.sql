use master
go

create database movie_rating
Go

use movie_rating
Go

/* Create the schema for our tables */
create table Movie(mID int, title varchar(50), year int, director varchar(50));
create table Reviewer(rID int, name varchar(50));
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

/*Даалгавар #1*/
/*1. Steven Spielberg -н зохиосон (directed) бүх киноны нэрийг харуул.*/
SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';

/*2. 4 эсвэл 5 гэсэн rating -тэй кино бүтээгдсэн бүх жилийг харуул. Мөн тэдгээр жилүүдийг өсөх эрэмбээр харуул.*/
SELECT year
FROM Movie
WHERE mID in (
	SELECT mID 
	FROM Rating 
	WHERE stars=4 or stars=5
	)
ORDER BY year ASC;

/*3. Rating -г байхгүй бүх киноны нэрсийг харуул.*/
SELECT title
FROM Movie
WHERE mID not in (
	SELECT mID 
	FROM Rating
	);

/*4. Нэг reviewer нэг киног 2 удаа үнэлгээ хийсэн байж болох бөгөөд 2 дах үнэлгээ нь эхнийхээсээ өндөр байх reviewer name and movie title -уудийг харуул.*/
SELECT name, title 
FROM Reviewer, Movie, Rating r1, Rating r2
WHERE r1.mID=Movie.mID and Reviewer.rID=r1.rID and r1.rID = r2.rID and r2.mID = Movie.mID and r1.stars < r2.stars and r1.ratingDate < r2.ratingDate;


/*Даалгавар #2*/
/*1. Өгөгдлийн уншихад амар болгох зорилгоор баганаар эрэмбэл. Reviewer name, movie title, stars, ratingDate-г дараах эрэмбийн дагуу харуулна уу. (1) reviewer name, (2) movie title (3) number of stars.*/
SELECT name, title, stars, ratingDate
FROM Movie, Rating, Reviewer
WHERE Movie.mId = Rating.mId AND Reviewer.rId = Rating.rId
ORDER BY name, title, stars;
Go

/*2. Ядаж нэг үнэлгээ авсан кинонуудын хувьд хамгийн өндөр үнэлгээг (star) олоод, киноны нэр болон одны тоог харуул. Харуулахдаа киноны нэрээр эрэмбэл.*/
SELECT title, MAX(stars)
FROM (SELECT DISTINCT Rating.mID, Rating.stars
	FROM Rating, Movie
	WHERE Movie.mID NOT IN (SELECT mID FROM Rating)
	) AS sub, Movie
WHERE sub.mID = Movie.mID
GROUP BY Movie.title
ORDER BY Movie.title
Go

/*3. Кино бүрийн үнэлгээний тархалтын талаарх мэдээллийг ол. Үнэлгээний тархалт гэдэг нь уг кинонд өгөгдсөн хамгийн өндөр болон бага үнэлгээний зөрүүг хэлнэ. Киноны нэр болон үнэлгээний тархалтыг буурах эрэмбээр  харуулна уу.*/
SELECT title, MAX(stars)-MIN(stars) AS tarhalt
FROM (SELECT DISTINCT Rating.mID, Rating.stars
	FROM Rating,Movie
	WHERE Movie.mID NOT IN (SELECT mID FROM Rating)
	) AS sub, Movie
WHERE Movie.mID = sub.mID
GROUP BY title
ORDER BY tarhalt DESC,title
Go

/*4. 1980 оноос өмнөх киноны үнэлгээнүүдийн дундаж ба 1980 оноос дараах (1980 ороод)  киноны үнэлгээнүүдийн дундаж 2-н зөрүүг олно уу. Жич: тухайн киноны дундаж үнэлгээг тэр киноны үнэлгээ гэж үзнэ.*/
SELECT AVG(bf.stars)-AVG(af.stars) AS zoruu
FROM (SELECT stars 
	FROM (SELECT Rating.mID, AVG(Rating.stars) AS stars
		FROM Rating
		GROUP BY mID
		) AS sub1, Movie
	WHERE sub1.mID=Movie.mID AND Movie.year<'1980'
	) as bf, (SELECT stars
			FROM (SELECT Rating.mID,AVG(Rating.stars) AS stars
				FROM Rating
				GROUP BY mID
				) AS sub2, Movie
				WHERE sub2.mID=Movie.mID AND Movie.year>'1980'
			) as af
Go