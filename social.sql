create database social
go

use social
go

/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name varchar(40), grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

/*1. Gabriel нэртэй сурагчтай найзын харицаатай бүх оюутнуудын нэрийг харуулна уу.*/
SELECT name
FROM Highschooler
WHERE ID IN (
	SELECT ID2
	FROM Friend
	WHERE ID1 IN (
		SELECT ID
		FROM Highschooler
		WHERE name = 'Gabriel')
);
GO

SELECT H1.name
FROM Highschooler H1
INNER JOIN Friend ON H1.ID = Friend.ID1
INNER JOIN Highschooler H2 ON H2.ID = Friend.ID2
WHERE H2.name = 'Gabriel';
GO

/*2. Өөрөөсөө 2-оос олон дүү хэн нэгэнд дуртай бүх сурагчдын нэр ангийг болон дуртай  сурагчийнх нь нэр ангийг харуул.*/
	SELECT HI1.name, HI1.grade, HI2.name, HI2.grade
	FROM Highschooler HI1, Highschooler HI2
	WHERE HI1.grade - HI2.grade >= 2 AND HI1.ID IN (
		SELECT ID1
		FROM Likes
		WHERE ID2 = HI2.ID
	);
GO

/*3. Өөр хоорондоо дуртай сурагчдийн хосуудын нэр ангиудыг харуул. Нэг хос давхцаж болохгүй ба нэрсийг цагаан толгойн дарааллаар харуулна уу.*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
WHERE (H1.ID = L1.ID1 AND H2.ID = L1.ID2) AND (H2.ID = L2.ID1 AND H1.ID = L2.ID2) AND H1.name < H2.name
ORDER BY H1.name, H2.name;
GO

/*4. Likes хүснэгтэд байхгүй бүх сурагчдын нэрсийг ангитай нь олж, анги, нэрээр эрэмбэлж харуулна уу.*/
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (
	SELECT DISTINCT ID1
	FROM Likes
	UNION
	SELECT DISTINCT ID2
	FROM Likes
)
ORDER BY name, grade;
GO

/*5. Сурагч А нь сурагч Б-д дуртай бөгөөд сурагч Б хэнд дуртай талаар мэдээлэл байхгүй (Б Likes хүснэгтэд id1 -р бичэгдээгүй) байх бүх тохиолдолыг олж, А болон Б-ийн нэр, ангийг нэрээр эрэмбэлж харуулна уу.*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1
INNER JOIN Likes ON H1.ID = Likes.ID1
INNER JOIN Highschooler H2 ON H2.ID = Likes.ID2
WHERE (H1.ID = Likes.ID1 AND H2.ID = Likes.ID2) AND H2.ID NOT IN (
  SELECT DISTINCT ID1
  FROM Likes
);

/*6. Зөвхөн нэг ижил ангид л найзууд нь байдаг сурагчдын нэр ангийг олж, анги нэрээр эрэмбэлж харуулна уу.*/
SELECT name, grade
FROM Highschooler H1
WHERE ID NOT IN (
	SELECT ID1
	FROM Friend, Highschooler H2
	WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2 AND H1.grade != H2.grade
)
ORDER BY grade, name;
GO

/*7. А, В сурагчид өөр хоорондоо найз биш хэдийч А сурагч нь В сурагчид дуртай бөгөөд тэд 2-уул С сурагчтай найз бол А,В,С гурвалын нэр ангийг харуул.*/
SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L1, Friend F1, Friend F2
WHERE (H1.ID = L1.ID1 AND H2.ID = L1.ID2) AND H2.ID NOT IN (
  SELECT ID2
  FROM Friend
  WHERE ID1 = H1.ID
) AND (H1.ID = F1.ID1 AND H3.ID = F1.ID2) AND (H2.ID = F2.ID1 AND H3.ID = F2.ID2);
GO

/*8. Уг сургуулийн хүүхдүүдийн тоо болон ялгаатай нэрний тооны зөрүүг ол.*/
SELECT COUNT(*) - COUNT(DISTINCT name)
FROM Highschooler;
GO

/*9. Хэрвээ тухайн нэг сурагчид нэгээс олон сурагч дуртай бол уг сурагчийн нэр ангийг харуул.*/
SELECT H.name, H.grade
FROM Highschooler H, (
	SELECT COUNT(*) AS ly, ID2
	FROM LIKES 
	GROUP BY ID2
) AS L
WHERE L.ID2 = H.ID AND L.ly > 1;
GO

/*10. Хэрвээ сурагч А нь сурагч В-д дуртай, харин Сурагч В нь сургагч С-д дуртай бол эдгээр сурагчдын анги нэрийг харуул.*/
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L1, Likes L2
WHERE H1.ID = L1.ID1 AND H2.ID = L1.ID2 AND (H2.ID = L2.ID1 AND H3.ID = L2.ID2 AND H3.ID != H1.ID);
GO

/*11. Бүх найзууд нь өөр ангид суралцдаг сурагчдын нэр ангийг харуул.*/
SELECT name, grade
FROM Highschooler H1
WHERE grade NOT IN (
	SELECT H2.grade
	FROM Friend, Highschooler H2
	WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2
);
GO

/*12. Оюутануудын найзуудын дундаж хэд вэ? Хариулт нэг тоо гарна.*/
SELECT AVG(A.naiz)
FROM (
	SELECT COUNT(*) AS naiz
	FROM Friend
	GROUP BY ID1
) AS A;
GO

/*13. Cassandra-н найзууд, мөн түүний найзуудтай найз байх оюутнуудын тоог олно уу. Cassandra -г энэ тоонд оруулахгүй.*/
SELECT COUNT(*)
FROM Friend
WHERE ID1 IN (
	SELECT ID2
	FROM Friend
	WHERE ID1 IN (
		SELECT ID
		FROM Highschooler
		WHERE name = 'Cassandra'
	)
);
GO

/*14. Хамгийн олон найзтай оюутанг олно уу.*/
SELECT H.name, H.grade
FROM Highschooler H, (
	SELECT COUNT(*) AS naiz, ID1
	FROM Friend
	GROUP BY ID1
) AS A
WHERE A.naiz = (
	SELECT MAX(M.naiz)
	FROM (
		SELECT COUNT(*) AS naiz, ID1
		FROM Friend
		GROUP BY ID1
	) AS M
) AND A.ID1 = H.ID;
GO