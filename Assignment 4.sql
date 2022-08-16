/*Өмнө ашигласан кино үнэлгээний (movie rating) өгөгдлийн санд доорх өөрчлөлт хийнэ үү.*/
USE movie_rating;
GO

/*1. Roger Ebert нэртэй шинэ шүүмж бичигчийг 209 rID -тайгаар өгөгдлийн сан руу нэмнэ үү.*/
INSERT INTO Reviewer VALUES (209, 'Roger Ebert');
GO

/*2. James Cameron бүх кинонд 5 үнэлгээ (star) өгөхөөр шийджээ. Түүний шийдвэрийг өгөгдлийн санд оруулна уу. Огноог NULL -р оруулна уу.*/
INSERT INTO Rating 
	SELECT (
		SELECT rID
		FROM Reviewer
		WHERE name = 'James Cameron'
	), mID, 5, NULL
	FROM Movie;
GO

DELETE FROM RATING
WHERE rID = (
	SELECT rID
	FROM Reviewer
	WHERE name = 'James Cameron'
) AND stars = 5 AND ratingDate = NULL;
GO

/*3. Дундаж үнэлгээ нь 4 буюу түүнээс дээш байх кино тус бүрийн нээлтээ хийсэн жилийг 25-р нэмэгдүүлнэ үү. Жич: шинэ мөр үүсгэхгүй, хуучин мөрөө өөрчилнө.*/
UPDATE Movie
SET year = year + 25
WHERE mID IN (
	SELECT mID
	FROM Rating
	GROUP BY mID
	HAVING AVG(stars) >= 4
)
GO

/*4. 1970-с өмнө эсвэл 2000-с хойш бүтээгдсэн бөгөөд 4-с бага үнэлгээ авч байсан бүх киног устгана уу.*/
DELETE FROM Movie
WHERE year <= 1970 AND year >= 2000 AND mID = (
	SELECT mID
	FROM RATING
	WHERE stars < 4
);
GO

DELETE FROM Rating
WHERE mID = (
	SELECT mID
	FROM MOVIE
	WHERE year < 1970 AND year > 2000
) AND stars < 4;
GO

/*5. Нэг кино-д нэг хүн 1 удаа л үнэлгээ өгдөг болов. Хэрэв олон удаа өгсөн бол аль өндөрийг үлдээе.*/

SELECT *
FROM Rating
WHERE 

/*Өмнө ашигласан social өгөгдлийн санд доорх өөрчлөлт хийнэ үү.*/
USE social;
GO

/*6. Highschooler-ээс бүх 12-р ангийн сурагчдыг устгая.*/
DELETE FROM Highschooler
WHERE grade = 12;
GO

/*7. Сурагч A болон B нь найзууд бөгөөд A нь B-д дуртай гэхдээ B нь A-д дуртай мэдээлэл байхгүй бол энэ 2 сурагчийн талаарх мэдээллийг Likes хүснэгтээс устгая.*/
SELECT *
FROM Likes L, Friend F
WHERE L.ID1 = F.ID1 AND L.ID2 = F.ID2;
GO

/*8. Сурагч А нь В-тэй найз, В нь С-тэй найз бол А,С-г найзууд болгож, Friend хүснэгтэд мэдээлэл нэмнэ үү (A,C нь найзууд бол дахин нэмэх шаардлагагүй, мөн сурагч өөртэйгээ найз болохгүй).*/
INSERT INTO Friend
	SELECT A.ID, C.ID
	FROM Highschooler A, Highschooler B, Highschooler C
	WHERE A.ID IN (
		SELECT ID1
		FROM Friend
		WHERE ID2 = B.ID
	) AND B.ID IN (
		SELECT ID1
		FROM Friend
		WHERE ID2 = C.ID
	) AND A.ID != C.ID;
GO

/*9. Өөр ангид найзтай сурагчидыг өөрийн ангийн бүх сурагчидтай найз болгоё.*/
SELECT DISTINCT *
FROM Highschooler H1, Highschooler H2
WHERE H1.ID IN (
	SELECT ID1
	FROM Friend
	WHERE H1.grade != H2.grade
)
GO

/*10. А сурагч Б сурагчид дуртай бөгөөд А сурагч нь Б сурагчтай найз биш бол найз болгоё.*/
INSERT INTO Friend
	SELECT A.ID, B.ID
	FROM Highschooler A, Highschooler B
	WHERE A.ID IN (
		SELECT ID1
		FROM Likes
		WHERE ID2 = B.ID
	) AND A.ID NOT IN (
		SELECT ID1
		FROM Friend
		WHERE ID2 = B.ID
	) AND A.ID != B.ID
GO

/*11. Ангидаа найзгүй сурагчийг ангийнхаа бүх сурагчид дуртай болгоё.*/
INSERT INTO LIKES
	SELECT A.ID, H.ID
	FROM Highschooler H, (
		SELECT ID, grade
		FROM Highschooler H1
		WHERE ID NOT IN (
			SELECT ID1
			FROM Friend, Highschooler H2
			WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2 AND H1.grade = H2.grade
		)
	) AS A
	WHERE A.grade = H.grade;
GO