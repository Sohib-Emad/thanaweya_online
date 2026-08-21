--
-- PostgreSQL database dump
--

\restrict fhLcuwboOeQbnIyDCUGI70g9K23plFVIv5cIHW5kSPgeviO7stdkfgMWEX0r9g8

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.4 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subjects (id, name_ar, name_en, icon_name, is_active, display_order, created_at) FROM stdin;
2e2fbd71-42dc-4c89-b684-aa3f0adb3b81	رياضيات	Mathematics	calculate	t	1	2026-07-21 02:08:27.435053+00
6ac2422a-f0bc-4513-918c-1772bff1e38b	فيزياء	Physics	science	t	2	2026-07-21 02:08:27.435053+00
fc1a4669-e18b-4ef9-907a-d83ef62d6323	كيمياء	Chemistry	science_outlined	t	3	2026-07-21 02:08:27.435053+00
27d99cbf-cc94-4371-aae0-9df04d498b8a	أحياء	Biology	eco	t	4	2026-07-21 02:08:27.435053+00
5356a563-644a-45e7-b708-55c616b4f095	لغة عربية	Arabic	menu_book	t	5	2026-07-21 02:08:27.435053+00
cf543cd8-4155-488c-a48b-c8ed4778067f	لغة إنجليزية	English	language	t	6	2026-07-21 02:08:27.435053+00
5d735415-fd44-4d65-95be-f78ad4bba565	لغة فرنسية	French	translate	t	7	2026-07-21 02:08:27.435053+00
57e729ca-2c03-41af-b2e1-4b943f309df3	تاريخ	History	history_edu	t	8	2026-07-21 02:08:27.435053+00
50e648b3-69b6-416c-8687-95f4e799e1de	جغرافيا	Geography	public	t	9	2026-07-21 02:08:27.435053+00
23168953-c01e-4e6f-ae43-f85c41d6f6c7	فلسفة	Philosophy	psychology	t	10	2026-07-21 02:08:27.435053+00
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plans (id, name, billing_period, price, max_students, max_courses, storage_limit_mb, is_active, display_order, created_at, updated_at) FROM stdin;
25c2b387-8ede-4bbd-a55f-e9822e07207c	الباقة الشهرية	monthly	99.99	\N	\N	\N	t	1	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
1be2c0a1-9eff-4106-a2c4-c9bdd73efada	باقة الفصل	term	249.99	\N	\N	\N	t	2	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
c29b59af-98c0-46ee-a58f-a4e19b2eb8e8	باقة السنة	yearly	599.99	\N	\N	\N	t	3	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, full_name, phone, role, avatar_url, created_at, updated_at) FROM stdin;
bfa781f8-3bc8-4601-8814-73c99cf589a1	omniaelkohail608@gmail.com	أمنية علاء منصور الكحيل	01012806115	student	\N	2026-08-12 15:41:46.255674+00	2026-08-13 00:49:49.079525+00
2bb7a3ea-da47-4d47-ac23-e35326458c87	me@gmail.com	test	01096462825	student	\N	2026-08-13 00:52:17.36569+00	2026-08-13 00:52:17.36569+00
e16b180a-0e82-4cd4-97b2-57eadb181b4a	dtdg@gmail.com	g	01096462825	student	\N	2026-08-13 03:12:03.280448+00	2026-08-13 03:12:03.280448+00
a7b5768d-1837-436e-9e00-0cd136db2fd6	youmnazidan06@gmail.com	يمني كارم زيدان	01095102757	student	\N	2026-08-13 06:19:04.001813+00	2026-08-13 06:19:04.001813+00
46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	salmamohamed1790@gmail.com	سلمي محمد النجار	01060867176	student	\N	2026-08-13 10:38:50.860921+00	2026-08-13 10:38:50.860921+00
f2836a0a-6e10-44e6-8194-c6d859ae8548	soon@gmail.com	slam	ewqrwqerwe	student	\N	2026-08-09 14:16:42.828186+00	2026-08-09 14:16:42.828186+00
4d817052-c05d-4927-a54b-7bbd5a128909	hasaninelsaid99@gmail.com	حسنين السيد محمد عتمان	01069114924	teacher	\N	2026-08-10 19:31:50.01769+00	2026-08-10 19:31:50.01769+00
56de2f45-5281-48a3-ac7f-8ce0c3300c46	tarekallam749@gmail.com	طارق علام شعبان علام	01090796360	student	\N	2026-08-12 15:35:51.751153+00	2026-08-12 15:35:51.751153+00
0d9a8081-3732-48e8-9d96-ddd4a2388e52	helalzedan2@gmail.com	هلال محمد نعيم مختار زيدان	01117695557	student	\N	2026-08-12 15:37:22.7137+00	2026-08-12 15:37:22.7137+00
5b876217-bc9e-4f3c-b66f-03f3cfeb2617	ahmednagy123543@gmail.com	احمد ناجي محمد عبد الصادق	01004305217	student	\N	2026-08-12 15:38:09.182396+00	2026-08-12 15:38:09.182396+00
79386e13-3ee0-43e9-ab80-de95d5b2a113	kareemmansor815@gmail.com	كريم صبحي محمد عبد الصادق	01024674984	student	\N	2026-08-12 15:38:52.578477+00	2026-08-12 15:38:52.578477+00
ab84b692-8481-494a-a677-a7e671a37a30	menakper@gmail.com	مينا انيس	01279183556	student	\N	2026-08-12 15:39:24.295052+00	2026-08-12 15:39:24.295052+00
fdf7ac58-4cc3-4e60-9a17-583f63c6c551	km3312521@gmail.com	كريم زغلول عبد العزيز	01032788003	student	\N	2026-08-12 15:43:29.455795+00	2026-08-12 15:43:29.455795+00
6c44f50e-cdc6-4de4-8274-1315e51fa09b	mansoryasmin3@gmail.com	ياسمين صبحي محمد عبدالصادق	01024674984	student	\N	2026-08-13 11:42:11.814874+00	2026-08-13 11:42:11.814874+00
2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	alizather1@gmail.com	محمد علي محمد فتحى زيتحار	01061704413	student	\N	2026-08-12 15:44:21.37172+00	2026-08-12 15:44:21.37172+00
5bc8b321-dda7-4d6d-888a-b758bc5162cd	ag7298742@gmail.com	احمد جلال بسيوني الخرادلي	01061260066	student	\N	2026-08-12 15:53:51.512377+00	2026-08-12 15:53:51.512377+00
6d8e3af7-873c-4303-9efd-45c9a9c6bb5a	omarelserafy36@gmail.com	عمر محمود الصيرفى	01553033744	student	\N	2026-08-12 15:55:32.246274+00	2026-08-12 15:55:32.246274+00
fd3b76ea-7205-4859-940b-d9725f5ebc00	rewasramzy842@gmail.com	رويس رمزي ذكي جرجس	01226400941	student	\N	2026-08-12 16:18:09.614492+00	2026-08-12 16:18:09.614492+00
f445ca66-2e02-414b-b661-483039071177	amp3456700@gmail.com	أحمد يوسف محبوب	01025204591	student	\N	2026-08-12 16:18:57.30092+00	2026-08-12 16:18:57.30092+00
10f030a2-883b-49a5-adc7-fe753c42ce5e	as2184363@gmail.com	ahmed serag	01096018287	student	\N	2026-08-12 16:20:37.015218+00	2026-08-12 16:20:37.015218+00
026c809c-79ab-4a19-a2e5-302cb224a67f	ryhikkvfdshkncjk@gmail.com	رحمه احمد حموده	01007600751	student	\N	2026-08-12 16:24:05.13615+00	2026-08-12 16:24:05.13615+00
9dfd72f1-514c-468a-befa-67090727970f	liverpooly011@gmail.com	ملك رضوان عباس خليفة	01062686330	student	\N	2026-08-12 16:39:25.534923+00	2026-08-12 16:39:25.534923+00
74e34941-6b14-4c9b-85c4-214494953b6d	olaatman987@gmail.com	علا علاء محمد عبد اللطيف عتمان	01507961250	student	\N	2026-08-12 16:41:10.606654+00	2026-08-12 16:43:47.971865+00
0c77846c-9906-4c72-98a0-f15f05b8f9b5	h9090897@gmail.com	حنين سعيد عبد الشافي	01286006824	student	\N	2026-08-12 16:45:36.189251+00	2026-08-12 16:45:36.189251+00
e2b106d2-7382-4f91-a640-20f948f921ac	zeadelsalamoni@gmail.com	زياد سعيد السلاموني	01098864414	student	\N	2026-08-12 17:08:36.456253+00	2026-08-12 17:08:36.456253+00
d9101537-bb4c-4b49-aaaf-384c50f0e645	heba.essam.elaasar@t2.com	هبه الله عصام السيد الاعصر	01095776440	student	\N	2026-08-12 17:35:43.086556+00	2026-08-12 17:35:43.086556+00
fd2e4f8a-030c-4698-b7cc-a39b647ee990	h01006916607@gmail.com	محمد حسين محمود النجار	01068519888	student	\N	2026-08-12 17:36:13.961024+00	2026-08-12 17:36:13.961024+00
12d743a4-bede-4102-8da0-f30b691c6574	ahmedessamzaied@gmail.com	أحمد عصام محمود زايد	01009725990	student	\N	2026-08-12 17:56:36.280445+00	2026-08-12 17:56:36.280445+00
2b2d5aad-f514-47a2-8912-b04421bf17cb	mlkm2011820@gmail.com	ملك محمود فتحى عواض	01008488558	student	\N	2026-08-12 18:16:41.198961+00	2026-08-12 18:16:41.198961+00
b795abfe-b02b-4de7-ad96-da7feab8ae24	rahlam041@gmail.com	أحلام رضا مختار زيدان	01007365709	student	\N	2026-08-12 20:12:55.812934+00	2026-08-12 20:12:55.812934+00
23988780-f6e0-4f0c-b62e-585f801a05d0	arwafawaz27@gmail.com	اروى فتحي فواز	01044843231	student	\N	2026-08-12 21:20:57.829852+00	2026-08-12 21:20:57.829852+00
4c463009-45b8-43c6-93c1-6e621ed2747f	elarabyz141@gmail.com	زياد عبد الحميد عبد المنعم محمد عبد الحميد العربي	01028516169	student	\N	2026-08-12 22:41:03.658017+00	2026-08-12 22:41:03.658017+00
86dcafc0-6fe0-4a18-b143-bad5e2ffa428	son@gmail.com	test	01096462825	student	\N	2026-08-13 00:41:43.325012+00	2026-08-13 00:41:43.325012+00
16128ef2-796d-47e9-a07e-87a5564eef99	fych@gmail.com	test	01096462825	teacher	\N	2026-08-13 00:49:18.562398+00	2026-08-13 00:49:18.562398+00
81a7e13f-5f9c-4f4b-9f8e-6b85f6ec388f	one.alietman@gmail.com	فاطمه على	01144404224	student	\N	2026-08-14 08:01:18.412343+00	2026-08-14 08:01:18.412343+00
fed40587-c5ad-4f3a-9c4e-c5345afb1cb7	mohammedfaied7@gmail.com	منة الله محمد فايد	01097398750	student	\N	2026-08-14 11:16:55.573071+00	2026-08-14 11:16:55.573071+00
8c15600d-1839-4654-8151-36b49828f40b	mya417607@gmail.com	مى ابراهيم محمد عبد الحميد حجازى	01005822294	student	\N	2026-08-14 11:19:37.989588+00	2026-08-14 11:19:37.989588+00
5d33f651-5b03-4bdb-b2e0-0137fdc5ece6	shimaaeshiba206@gmail.com	الشيماء محمد مهدى عشيبه	01014905720	student	\N	2026-08-14 16:03:32.203894+00	2026-08-14 16:03:32.203894+00
a3f6fd58-f635-4fbd-b4d0-86989a1bca35	esraaheikal67@gmail.com	اسراء وليد سعيد هيكل	01062434146	student	\N	2026-08-14 16:42:11.75852+00	2026-08-14 16:42:11.75852+00
0fd41d13-ce68-4892-864d-49215a367099	nourelhefnawy789@gmail.com	نور عبدالحميد الحفناوى	01037209635	student	\N	2026-08-15 18:17:40.396452+00	2026-08-15 18:17:40.396452+00
b1a1b863-e500-4bb9-ba77-decd072c906a	saraenab20202013@gmail.com	امير فتحي	01067553922	student	\N	2026-08-17 11:38:42.938166+00	2026-08-17 11:38:42.938166+00
c5bd97aa-af9d-4214-a249-f3183d5c08fb	mhmdteka51@gmail.com	ليلى وليد محمد جاد عتمان	01030661951	student	\N	2026-08-12 18:41:16.546815+00	2026-08-17 20:27:13.691198+00
86f11a35-f071-4269-860e-acd71068fdf9	hudaabdelhamid075@emil	HudaAbdElhamid	01092668638	student	\N	2026-08-18 21:21:10.738723+00	2026-08-18 21:21:10.738723+00
aa6465ff-e3d9-4c9a-a9a2-12df6decc5c4	ndy89450@gmail.com	ندي احمد محمد عبد المجيد زيدان	01010757930	student	\N	2026-08-19 06:17:13.799516+00	2026-08-19 06:17:13.799516+00
cbaf9ba6-08a6-4821-ac3c-0f5968710e05	jm33460071411@gmail.com	جنا محمد شعبان حلمي محمد البنا	01012800842	student	\N	2026-08-19 20:55:32.231207+00	2026-08-19 20:55:32.231207+00
fc2362a4-d534-4848-a9bd-497a6abf783e	ahmedramadanfathy2010@gmail.com	أحمد رمضان العتر	01012230257	student	\N	2026-08-12 18:50:56.809173+00	2026-08-21 09:28:28.589858+00
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teachers (id, subject_id, stage, bio, approval_status, rejection_reason, subscription_plan_id, subscription_expires_at, created_at, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url, teaching_system, governorate, teaching_mode, stages, baccalaureate_tracks) FROM stdin;
4d817052-c05d-4927-a54b-7bbd5a128909	5356a563-644a-45e7-b708-55c616b4f095	first	كبير معلمين لغة عربية ث عامة\nليسانس دار العلوم( لغة عربية وعلوم إسلامية )\nمدرسة شبراخيت الثانوية للبنات	approved	\N	\N	\N	2026-08-10 19:31:54.446515+00	\N	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/id_front/1786390310035.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/id_back/1786390311557.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/proof/1786390313155.jpg	general	الإسكندرية	both	{first,second,third}	{}
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.courses (id, teacher_id, title, description, cover_image_url, is_published, "order", created_at, updated_at, price, intro_video_url, intro_video_source_type) FROM stdin;
24a9a7a7-2f6e-4696-8883-35d4984be8e6	4d817052-c05d-4927-a54b-7bbd5a128909	شرح أساسيات البلاغة للصف الأول الثانوي والبكالوريا	شرح أساسيات البلاغة والتدريب عليها	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/covers/1786465111720/1786465111721.png	t	0	2026-08-11 16:18:32.639323+00	2026-08-13 02:33:50.748646+00	150.00	\N	youtube
b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	4d817052-c05d-4927-a54b-7bbd5a128909	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي	شرح وتدريبات علي المشتقات والمصادر والمقصور والمنقوص والممدود واسما الزمان والمكان	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/covers/1786462514599/1786462514599.png	t	0	2026-08-11 15:35:16.047238+00	2026-08-14 23:54:49.598838+00	150.00	\N	youtube
8bd82ceb-8a48-4449-baac-fd8901f317bd	4d817052-c05d-4927-a54b-7bbd5a128909	منهج القواعد النحوية للصف الأول الثانوي بكالوريا	شرح وتدريبات علي منهج النحو النواسخ وإعمال المشتقات	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/covers/1786908161027/1786908161028.png	t	0	2026-08-16 19:22:42.282156+00	2026-08-16 19:22:49.490454+00	150.00	\N	youtube
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.students (id, grade_level, parent_phone, created_at) FROM stdin;
f2836a0a-6e10-44e6-8194-c6d859ae8548	first	01000000000	2026-08-09 14:16:43.055975+00
56de2f45-5281-48a3-ac7f-8ce0c3300c46	third	01090796360	2026-08-12 15:35:52.10742+00
0d9a8081-3732-48e8-9d96-ddd4a2388e52	second	01117695557	2026-08-12 15:37:22.906704+00
5b876217-bc9e-4f3c-b66f-03f3cfeb2617	third	01004305217	2026-08-12 15:38:09.293603+00
79386e13-3ee0-43e9-ab80-de95d5b2a113	third	01024674984	2026-08-12 15:38:52.720404+00
ab84b692-8481-494a-a677-a7e671a37a30	first	01279183556	2026-08-12 15:39:26.152234+00
bfa781f8-3bc8-4601-8814-73c99cf589a1	second	01012806115	2026-08-12 15:41:46.376059+00
fdf7ac58-4cc3-4e60-9a17-583f63c6c551	second	01032788003	2026-08-12 15:43:29.597667+00
2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	second	01061704413	2026-08-12 15:44:21.68021+00
5bc8b321-dda7-4d6d-888a-b758bc5162cd	first	01061260066	2026-08-12 15:53:51.682017+00
6d8e3af7-873c-4303-9efd-45c9a9c6bb5a	second	01553033744	2026-08-12 15:55:32.421776+00
fd3b76ea-7205-4859-940b-d9725f5ebc00	first	01226400941	2026-08-12 16:18:09.845083+00
f445ca66-2e02-414b-b661-483039071177	third	01025204591	2026-08-12 16:18:57.50385+00
10f030a2-883b-49a5-adc7-fe753c42ce5e	first	01000000000	2026-08-12 16:20:37.214511+00
026c809c-79ab-4a19-a2e5-302cb224a67f	third	01007600751	2026-08-12 16:24:05.647211+00
9dfd72f1-514c-468a-befa-67090727970f	first	01062686330	2026-08-12 16:39:25.680841+00
74e34941-6b14-4c9b-85c4-214494953b6d	third	01092528227	2026-08-12 16:41:10.726979+00
0c77846c-9906-4c72-98a0-f15f05b8f9b5	second	01286006824	2026-08-12 16:45:36.351009+00
e2b106d2-7382-4f91-a640-20f948f921ac	third	01098864414	2026-08-12 17:08:36.782292+00
d9101537-bb4c-4b49-aaaf-384c50f0e645	first	01095776440	2026-08-12 17:35:43.32633+00
fd2e4f8a-030c-4698-b7cc-a39b647ee990	second	01068519888	2026-08-12 17:36:14.113904+00
12d743a4-bede-4102-8da0-f30b691c6574	third	01009725990	2026-08-12 17:56:36.554392+00
2b2d5aad-f514-47a2-8912-b04421bf17cb	first	01008488558	2026-08-12 18:16:41.532363+00
c5bd97aa-af9d-4214-a249-f3183d5c08fb	first	01030661951	2026-08-12 18:41:16.722158+00
fc2362a4-d534-4848-a9bd-497a6abf783e	first	01012230257	2026-08-12 18:50:56.968062+00
b795abfe-b02b-4de7-ad96-da7feab8ae24	third	01007365709	2026-08-12 20:12:56.078685+00
23988780-f6e0-4f0c-b62e-585f801a05d0	third	01044843231	2026-08-12 21:20:58.028477+00
4c463009-45b8-43c6-93c1-6e621ed2747f	third	01028516169	2026-08-12 22:41:03.876363+00
86dcafc0-6fe0-4a18-b143-bad5e2ffa428	third	01096462825	2026-08-13 00:41:43.447946+00
2bb7a3ea-da47-4d47-ac23-e35326458c87	third	01096462825	2026-08-13 00:52:17.496961+00
e16b180a-0e82-4cd4-97b2-57eadb181b4a	third	01096462825	2026-08-13 03:12:03.718505+00
a7b5768d-1837-436e-9e00-0cd136db2fd6	third	01095102757	2026-08-13 06:19:04.181411+00
46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	first	01060867176	2026-08-13 10:38:51.078151+00
6c44f50e-cdc6-4de4-8274-1315e51fa09b	first	01024674984	2026-08-13 11:42:12.69602+00
81a7e13f-5f9c-4f4b-9f8e-6b85f6ec388f	first	01144404224	2026-08-14 08:01:18.694889+00
fed40587-c5ad-4f3a-9c4e-c5345afb1cb7	second	01097398750	2026-08-14 11:16:55.730965+00
8c15600d-1839-4654-8151-36b49828f40b	first	01000000000	2026-08-14 11:19:38.203783+00
5d33f651-5b03-4bdb-b2e0-0137fdc5ece6	second	01014905720	2026-08-14 16:03:32.720872+00
a3f6fd58-f635-4fbd-b4d0-86989a1bca35	third	01062434146	2026-08-14 16:42:11.916509+00
0fd41d13-ce68-4892-864d-49215a367099	second	01037209635	2026-08-15 18:17:40.645103+00
b1a1b863-e500-4bb9-ba77-decd072c906a	third	01067553922	2026-08-17 11:38:43.114027+00
86f11a35-f071-4269-860e-acd71068fdf9	first	01092668638	2026-08-18 21:21:11.022575+00
aa6465ff-e3d9-4c9a-a9a2-12df6decc5c4	first	01010757930	2026-08-19 06:17:14.086939+00
cbaf9ba6-08a6-4821-ac3c-0f5968710e05	first	01012800842	2026-08-19 20:55:33.639938+00
\.


--
-- Data for Name: activation_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activation_codes (id, teacher_id, course_id, code, is_used, used_by, used_at, created_at) FROM stdin;
4fd0d827-4954-486d-a22a-35ca69e315c0	4d817052-c05d-4927-a54b-7bbd5a128909	\N	TH-QCKQ-DEJX	t	e16b180a-0e82-4cd4-97b2-57eadb181b4a	2026-08-13 03:12:16.639843+00	2026-08-13 03:08:09.150987+00
\.


--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookmarks (id, student_id, course_id, created_at) FROM stdin;
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lessons (id, course_id, title, description, video_source_type, video_url_or_id, duration_seconds, thumbnail_url, is_free_preview, "order", created_at, updated_at, max_views) FROM stdin;
445b0259-5e81-4e64-82df-a4d7ef27ecec	24a9a7a7-2f6e-4696-8883-35d4984be8e6	الاستعارة وأنواعها	شرح الاستعارة المكنية والتصريحية وكيفية التمييز بينهما	youtube	https://youtu.be/-F0CFaecpCM?si=pI2qGs7IISO14XO1	\N	\N	f	0	2026-08-11 16:41:45.455199+00	2026-08-11 16:41:45.455199+00	3
aa6545c3-7eda-4dd5-b3af-2e7c36355d75	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التشبيه وأنواعه والتدريب عليه	شرح الفرق بين التشبيه المفرد والمركب والتمييز بينهما	youtube	https://youtu.be/2PIatAZOQds?si=EVeBJVWwKiQtrmMp	\N	\N	f	0	2026-08-11 16:29:56.254123+00	2026-08-11 16:42:00.752142+00	3
5a01509e-1631-4e3b-bc8c-45a87f2180af	24a9a7a7-2f6e-4696-8883-35d4984be8e6	تطبيقات علي الاستعارة بأنواعها	بيان كيفية حل الأسئلة الخاصة بالاستعارة	youtube	https://youtu.be/T0xRicCDT2U?si=j2F8ajuLVBtY60Qd	\N	\N	f	0	2026-08-11 16:45:39.906384+00	2026-08-11 16:45:39.906384+00	3
9a641534-3a1c-4004-a16b-e9b8a1f4d180	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	أسلوب التفضيل وحالات اسم التفضيل	أسلوب التفضيل وصياغته وحالات اسم التفضيل وحكم مطابقته مع المفضل	youtube	https://youtu.be/UW7P5XsGrn8?si=S5aZttqMf7ZB2QQy	\N	\N	t	0	2026-08-11 15:37:59.513904+00	2026-08-11 15:38:42.283315+00	3
fbac0173-d456-4fbb-8969-0eb7f291cd90	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اسم المفعول صياغته وإعماله	شرح صياغة اسم المفعول وكيفية إعماله	youtube	https://youtu.be/RC_A6LyoQEY?si=bG6BcdNO4yHGBzQ1	\N	\N	f	0	2026-08-11 15:43:46.450888+00	2026-08-11 15:43:46.450888+00	3
18854bc6-3dd0-460f-a3aa-9e4a8d264fd0	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تطبيقات على المشتقات واسم التفضيل	تطبيقات وتدريبات متنوعة علي إعمال المشتقات وأسلوب التفضيل	youtube	https://youtu.be/S26fuTf0obs?si=FOiUO3SvnwcWf_bM	\N	\N	f	0	2026-08-11 15:50:45.004634+00	2026-08-11 15:50:45.004634+00	3
f2a876cd-5bc0-4afa-9f6f-3ce4b387b0c2	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اسم الفاعل صياغته وإعماله	شرح اسم الفاعل وكيفية صياغته وإعماله والتدريب عليها	youtube	https://youtu.be/DIddTXDGQns?si=WHzRQqfHN_Q6zkjx	\N	\N	f	0	2026-08-11 15:53:53.911155+00	2026-08-11 15:53:53.911155+00	3
201176ba-ab82-4824-8dc3-c2a2fd704e4f	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	صيغ المبالغة كيفية صياغتها وإعمالها	شرح صيغ المبالغة وكيفية صياغتها وإعمالها والتدريب عليها	youtube	https://youtu.be/F-_2CYNmtrI?si=B6cx_lep4TSRANxa	\N	\N	f	0	2026-08-11 16:00:46.491347+00	2026-08-11 16:00:46.491347+00	3
aa8be204-c7d0-4b1a-afc3-6c0bc8431dd7	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	المصادر الصريحة( السماعي والقياسي )	شرح المصدر الصريح السماعي والقياسي والتدريب عليها	youtube	https://youtu.be/MetvwWkH3pw?si=mJnotV5qbxFI_qTy	\N	\N	f	0	2026-08-11 16:11:48.435+00	2026-08-11 16:11:48.435+00	3
8db68ef3-c4d3-464d-a43e-4140ead18b3c	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التعبير الحقيقي والتعبير المجازي	شرح الفرق بين التعبير الحقيقي والتعبير المجازي والتدريب عليهما	youtube	https://youtu.be/mH7X5qUvJHo?si=SHrVZDONhv1mYxHp	\N	\N	f	0	2026-08-11 16:26:56.91837+00	2026-08-11 16:26:56.91837+00	3
869f5d83-64fa-46da-bd81-2bde4d66b808	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التشبيه المركب والتمييز بينهما	شرح التشبيه المركب التمثيلي والضمني وكيفية التمييز بينهما	youtube	https://youtu.be/Xud_pATLJmg?si=FbW2T-6gAFkmKryF	\N	\N	f	0	2026-08-11 16:34:23.539976+00	2026-08-11 16:34:23.539976+00	3
99e5ab0c-49ea-4c56-b38d-67602693cdf0	24a9a7a7-2f6e-4696-8883-35d4984be8e6	تطبيقات على التشبيه	أمثلة متنوعة وتطبيقات علي التشبيه بأنواعه	youtube	https://youtu.be/7ScbSer4yfQ?si=A_DOOVR-5ldYLRbF	\N	\N	f	0	2026-08-11 16:37:34.62186+00	2026-08-11 16:37:34.62186+00	3
24b19459-03d5-460b-a6ca-b741bf97add2	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	المصدر الميمي والمصدر الصناعي	شرح المصدر الميمي وصياغته \nوالمصدر الصناعي	youtube	https://youtu.be/er5wf1ajG8s?si=n0dnuVbfPaGHfTby	\N	\N	f	0	2026-08-14 23:56:37.738515+00	2026-08-14 23:56:37.738515+00	3
642cfaf8-ee0a-42e9-8dc0-1dcdd1cf636c	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اسما الزمان والمكان	شرح اسمي الزمان والمكان وصياغتهما من الثلاثي وغير الثلاثي	youtube	https://youtu.be/RNRFkAiWUWI?si=S2qp28n55b4Ai20z	\N	\N	f	0	2026-08-15 17:14:32.966115+00	2026-08-15 17:14:32.966115+00	3
59a13841-ac0d-4bc3-977b-8245b8d2c96a	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تدريبات على اسمي الزمان والمكان	تطبيقات علي اسمي الزمان والمكان	youtube	https://youtu.be/ETN6me5_-NM?si=NJ68tSw7qk0-XQch	\N	\N	f	0	2026-08-15 17:17:32.798584+00	2026-08-15 17:17:32.798584+00	3
678f5c76-3f05-4e46-837a-b1d1bc1968db	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	المصدر المؤول وكيفية إعرابه	صور المصدر المؤول وكيفية تحويله إلي مصدر صريح وكيفية معرفة محله الإعرابي	youtube	https://youtu.be/xpmYO9j48P0?si=BwXgTXSfOhELjk4u	\N	\N	f	0	2026-08-15 18:59:14.281666+00	2026-08-15 18:59:14.281666+00	3
eac3416f-add2-4d87-ac96-4aeb2ac4ffd1	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	الاسم المقصور تثنيته وجمعه جمعا سالما	كيفية معرفة الاسم المقصور وكيفية تثنيته وجمعه جمعا سالما	youtube	https://youtu.be/0gtHgCtl9aA?si=cOqNrxHzhOgxhxKn	\N	\N	f	0	2026-08-15 19:04:00.346375+00	2026-08-15 19:04:00.346375+00	3
ba5904b7-a6be-4308-81b6-422c25a57974	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	الاسم المنقوص تثنيته وجمعه جمعا سالما	كيفية معرفة الاسم المنقوص وكيفية تثنيته وجمعه جمعا سالما والتدريب عليها	youtube	https://youtu.be/GxQFgKHHRJk?si=f_zDq-t-Bx112Hij	\N	\N	f	0	2026-08-15 19:06:49.205102+00	2026-08-15 19:06:49.205102+00	3
b32dadff-3810-4c94-a7a1-2bc4f54fe5ee	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تطبيقات عامة علي الوحدة الثانية رقم ١	تدريبات متنوعة من واقع الامتحانات علي الوحدة الثانية	youtube	https://youtu.be/IfZoOPzPYtY?si=RyIBbb4on2tDAEbg	\N	\N	f	0	2026-08-15 19:12:01.732015+00	2026-08-15 19:12:01.732015+00	3
c59a2106-b867-4cdf-bc57-05e84c391a76	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تدريبات علي المصدر الميمي والصناعي	\N	youtube	https://youtu.be/fomtJkflhjY?si=LpmbT999INa99JTO	\N	\N	f	0	2026-08-15 19:13:39.499543+00	2026-08-15 19:13:39.499543+00	3
dc64a150-b03a-4aba-82d4-e18e1a8d5276	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تطبيقات على الوحدة الثانية رقم ٢	تدريبات متنوعة مهمة من واقع الامتحانات علي الوحدة الثانية	youtube	https://youtu.be/ipDZkd_R-Cs?si=vFo5jQV8sxi-0nqu	\N	\N	f	0	2026-08-15 19:18:35.702368+00	2026-08-15 19:18:35.702368+00	3
3018058b-3f24-4a61-ad32-96ee5257a62c	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	الاسم الممدود تثنيته وجمعه جمعا سالما	كيفية معرفة الاسم الممدود وكيفية تثنيته وجمعه جمعا سالما	youtube	https://youtu.be/IrjBtGEp6uA?si=VEhmr72LYYYk6lhr	\N	\N	f	0	2026-08-15 19:20:44.470815+00	2026-08-15 19:20:44.470815+00	3
bc72500f-7ad6-44f4-944b-ed1e5f1a1d41	8bd82ceb-8a48-4449-baac-fd8901f317bd	تدريبات مراجعة نحوية مهمة علي ما سبق دراسته	شرح وتدريبات لأهم القواعد التي تمت دراستها في المرحلة الإعدادية	youtube	https://youtu.be/30Yn1Rvo-W0?si=tl-2rn1aTMFGRRJw	\N	\N	t	0	2026-08-16 19:26:30.758195+00	2026-08-16 19:26:30.758195+00	3
08663c7a-7045-49f9-af88-e8431b9ef4e3	8bd82ceb-8a48-4449-baac-fd8901f317bd	شرح الأفعال الناسخة( كان وأخواتها )	شرح تفصيلي للنواسخ( كان وأخواتها )	youtube	https://youtu.be/F5fb6ZUx0pg?si=LhUO30cjvQS4gyiD	\N	\N	f	0	2026-08-16 19:35:14.231097+00	2026-08-16 19:35:14.231097+00	3
a5705bfa-7342-4dc3-802d-0983c4e6312e	8bd82ceb-8a48-4449-baac-fd8901f317bd	تدريبات مهمة ومتميزة علي كان وأخواتها	\N	youtube	https://youtu.be/yZl6jDS78qA?si=d9ErRAS7XH_32ubw	\N	\N	f	0	2026-08-16 19:37:21.529983+00	2026-08-16 19:37:21.529983+00	3
e5bec79a-311c-4e4c-9066-70af8ddce355	8bd82ceb-8a48-4449-baac-fd8901f317bd	الأفعال الناقصة والتامة المحاضرة الثانية	\N	youtube	https://youtu.be/pXywZdan-9o?si=3U1Xov2XwaR_mrTx	\N	\N	f	0	2026-08-16 19:41:17.829703+00	2026-08-16 19:41:17.829703+00	3
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, lesson_id, author_id, text, created_at) FROM stdin;
\.


--
-- Data for Name: course_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.course_reviews (id, course_id, student_id, rating, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.device_tokens (id, user_id, token, platform, created_at, updated_at) FROM stdin;
97c53788-19ff-4c2e-ad96-ad518acb111c	ab84b692-8481-494a-a677-a7e671a37a30	d1h4WjoURda7QM7lLhX6Z3:APA91bE2QZDvGpwKtpYGYfNE6v8-ZHKoAtiGdv8WrmGFkgpLNTBNhSXomNK8oKpJb3HmlwconHh1AYC0CxU9MGs2GWuAVQQfO7RtQik38t_c7rGTBBWhuxc	android	2026-08-12 15:39:25.117031+00	2026-08-12 15:39:22.801501+00
e1c47b55-b6a9-4579-982e-ad85362f381b	fdf7ac58-4cc3-4e60-9a17-583f63c6c551	ex4oslVqSRWMD2xLsYbd9y:APA91bHPpF2pEcBHKWUIm188gNfbEC_Ldfcv288x_gqg47PPY1o2__GMf5vSFU-PzRWaE_QOX8JdldbS3EEq0e6BXHHcvxcZI4ZgFULPgPtu74ws3djjhAM	android	2026-08-12 15:43:57.865003+00	2026-08-12 15:43:57.636326+00
6a674adf-ab2c-42cd-9d23-65bc5fe42b8e	2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	e5v3W5RuQfCJeHe8nGb0c2:APA91bHTjMnixBdib6mdK_bLvFDZHVnZSVjF81CFfPXJNGPHuKPHacQQTnEhcP6UutaVmNX0xoNnusNVZbFggDIfP46LbA88Em3vAeGr5nBIcewbiSx2V50	android	2026-08-12 15:44:21.506453+00	2026-08-12 15:44:19.154514+00
a1ec3636-1f51-4d46-859c-4ee20e93d368	4d817052-c05d-4927-a54b-7bbd5a128909	czGRP6JPRmy5MLhFJ4NzxF:APA91bHT9Tm5HhdmGUNASYR8hFmFnxbA6TivZ9WLb-aM9MDdJ4wary7pGhuyXlVbYh-Rj5rWHOYT7HogKf6h91Bl7ZXXzpN7z0nPlSEweGpBb5FXdSD6njM	android	2026-08-10 20:59:31.602061+00	2026-08-14 09:11:45.440199+00
358dc6eb-c96c-4c81-b603-3c3c8c6d272f	0d9a8081-3732-48e8-9d96-ddd4a2388e52	f5D-64y4RyCHB_ENDGX7g6:APA91bESqrLTeBuNeyfs2BLMDNxe3qRDtJSU_psLOeAnnBgsCCFuQlDW4pzx3HV11msY4GooZTFFpQJa0Q5bGVmky6kTHgi9xYFaBAmWndQV_N_nrfxhcCs	android	2026-08-12 19:46:33.651637+00	2026-08-13 18:53:56.963664+00
ff9a0bc6-9c29-48f5-910a-424af841893e	bfa781f8-3bc8-4601-8814-73c99cf589a1	dFvNB5LBR1K1YI-AA_xTPH:APA91bEjcesre2MWnu_wPMtDhlthR2QjSILDOOfHSZUj4Z1wn9EVPOwyRuBbzEPnjcyCLOYkjxzSNYtDOnaDlhT4gKRzKdEZz4k-lWghIJqeJQ1WgFYylvg	android	2026-08-12 15:41:46.271203+00	2026-08-13 22:03:14.40506+00
5fc9e866-0bc2-415c-90bb-6b6f6fe8a89a	10f030a2-883b-49a5-adc7-fe753c42ce5e	f3r5fmofQSOa96gnuTBjL-:APA91bHBI5hWEE84UZ8igocK2RZGJNcQH_VP1e-Gmbzg80rvagbO4A31152E1iDWXqyzft-xRlQen_vw-X00tKkHbM7gWVnW4xTl_6L0cLxn1hgKnQH5YO4	android	2026-08-12 17:37:10.970604+00	2026-08-12 17:37:10.559998+00
8e6ef09e-81ef-4122-aae2-0a8fdd2644c6	12d743a4-bede-4102-8da0-f30b691c6574	dBQYT7NjSsGjJOYsOVVGu1:APA91bHJgb6N91GUqP-lYuFk0hOK5BmHB6uMBZa7Bza_-o2duNsicAaOO1Yn_bqLOzQV60VAygF4CrN6bW3JArJUfghxYMl4eAgvRCLSzkPaNhPU8uKYCVk	android	2026-08-12 17:56:36.361387+00	2026-08-12 18:55:40.975664+00
2f57d34a-6dcb-4f6f-9ed4-380efe6633f0	2b2d5aad-f514-47a2-8912-b04421bf17cb	eRzuXN6KQMmFWlSEN6ypAT:APA91bFKmNRBBn35YCw7CAgG7asaH-P-_ZJFYDVfYpsNx-aapp0q3GXDH53cIfvIZV_82TzIV5jbTGksX-QYrllYHQL3-fOQO-Ub3nY_MfZ7ZYXYhAwp5Go	android	2026-08-12 18:16:41.299388+00	2026-08-12 18:16:40.416574+00
574cd2d9-f906-42c0-ae11-37dd8e1b6add	6c44f50e-cdc6-4de4-8274-1315e51fa09b	fKJ0a2CNR2untsm4OpLtbc:APA91bGe67CBZs7ZN61I8PISCgWFbYnBFLTOpf6zUKLj1bFHno5giiTnYQeWho8kMqNGpMWcG2PCaME1uCLvgfcV3oscs5S39BqhKRSiRmRVfmwNnNl2Dzk	android	2026-08-13 16:22:43.159023+00	2026-08-13 17:22:24.072848+00
0099f004-9da0-40fa-871d-65dc5762c213	fc2362a4-d534-4848-a9bd-497a6abf783e	d4mKcRWTRP-23fdSJ2QR-n:APA91bHShabxzfnpbt1Csbday9hEKUEkzE_w9d8wCcFbkBs6RyykTRqY-5uEqwk35JXdjy9Uh1uQ1_NncFkMBUPOlR2UcHBcg_G0JKLJ9pKY1KmA2WsEros	android	2026-08-12 18:50:59.138441+00	2026-08-12 18:50:58.614816+00
d59ac1c4-20c0-4e2d-9b4c-dda3b4cf6d27	026c809c-79ab-4a19-a2e5-302cb224a67f	do4D8a3uTBqUSKnraOpNcc:APA91bHuHnx5x6fXdlutw-h7RmCk7rbIYshfcdhYRGa8UlJ2-bx5uBuojc5mRmGMfm5i16dFUyJfdZLxmHXftdRBOhtnNSZlZFgVC3kQc8_Lay_0o2hJuXw	android	2026-08-12 16:24:05.266619+00	2026-08-12 20:05:33.49389+00
58a2bd9c-005b-4369-b848-80f520e13a8e	4c463009-45b8-43c6-93c1-6e621ed2747f	dQyZ6IH5QGCphFUDtU0bj4:APA91bG9x8cVDe3ogQKJEnZUN1pACBeXK32H3f0cRYfQyOX8vtcYG-XMV8HvJb0DJo9TdwD-ety4U42twzsT5YG-5ozYGhrIXek_PvB7Vk4yy3EsN_hbO8I	android	2026-08-12 22:41:03.676364+00	2026-08-12 22:39:54.788193+00
66cc482f-40fd-4033-ad36-5aca1be527c3	f2836a0a-6e10-44e6-8194-c6d859ae8548	ftFOVMNMQGyLJ1dUWJMyrb:APA91bEeP26bv2Oo3aIGFSLxZF1tJaQCB5MMUtDvvZ2te6GxvtzQ3x0wOwSAVjVLeJsak-QYPSWvl6po3-CdTl_JM-O2KkXGOyZheH2-EwWzPdq44GkLhkg	android	2026-08-13 00:39:51.213677+00	2026-08-13 00:39:50.57988+00
869160e3-6078-48e6-a716-d512a86ccd2a	5bc8b321-dda7-4d6d-888a-b758bc5162cd	eFa_0AecQMWFMybtcSFJ0l:APA91bGS-J-XQyZWV-3srLvBoIGKB8VXEo3WCNdZxbewIwQXUhFfKMDRRLH-vvfJXJPyrzo-pavKCspfL-8taS7hrSlK0StzRWyRj2BzyVBAkC3w5XYCM7A	android	2026-08-12 15:56:03.239759+00	2026-08-13 22:17:51.903322+00
89167b8b-de5f-45cf-9ddf-9a4577c1bca4	c5bd97aa-af9d-4214-a249-f3183d5c08fb	e5Y6usJEQoileTQNt7lxzv:APA91bFNDl_n7TqNgcTHQwJlel6HRKUkGBNbYPbWiXrDHla3yG5A0UmkqkEwfuWOKoysTf3SO7ojJQoOXChppLovsCnQ3sMH3tZUeg2H7pLmLi0CH3sr1W0	android	2026-08-12 19:40:21.715349+00	2026-08-13 22:36:59.064049+00
1223ea41-7da7-47a8-8568-741b0cf311e7	74e34941-6b14-4c9b-85c4-214494953b6d	cmR2JfV0RduL2Iw7Y_GLU4:APA91bFtGhtNn-vrUmoFg4SUkICzUg883kMol6_0-Hp0vY0xSarHkLztHX1mQkThY8YFpC8K2QQuz8PQA9oy2ltlzTxgSCXxG4oG99n0oCVMCJ4-Y08cKLQ	android	2026-08-13 09:22:00.088056+00	2026-08-13 12:15:24.71978+00
9ca23656-ac9a-473f-99b0-8c8355f25dfa	46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	fc3OULD7Qi6Iic7v7yLvBg:APA91bEhZXIAK9pyYZtcRsoyPRsVOF7Ya4CnBvfI5-FdrnqJGcY_wdvwLQisMiwMVCr6xlOyAQ42EjVt6k5P8fD3XOEDjKBKL-O5iiwVG4ZRC-St_FP01sY	android	2026-08-13 10:38:50.91414+00	2026-08-13 16:01:07.502813+00
75f2012f-b0df-41b4-aaae-9843bd67737b	fd3b76ea-7205-4859-940b-d9725f5ebc00	d0cmHwJARtq0k9BF6ejHgP:APA91bGmhy8OaDP9QNaUt2LPSU312X2UVuiHlIXpFm17wNrEXTCeZKTPyys8WE9kNoHIz7IflT2s9NlNGmmo2uQp_Uz6ClzokvhvOj-iPkmFmRQmf36tP9E	android	2026-08-12 17:17:22.804671+00	2026-08-13 15:49:45.060046+00
4dc284b5-b7c3-4e25-b3cb-b6988ee16d4a	fd2e4f8a-030c-4698-b7cc-a39b647ee990	dbwdk8FHSVCOqwzKb76i-_:APA91bHOJPsLUIxQKx4zj1RRoW7jkevx2I2BMLa4Kr60q74yxSo8vD9AnVeGl1lzSTaZyxHWbhbbCjncCZUACx2CKW1gZhOxXyqXpjh-LdOP4w6yVRJPAOk	android	2026-08-12 17:36:13.975239+00	2026-08-13 17:00:11.775725+00
fa2cf145-61b4-405f-9480-7af5c093c994	81a7e13f-5f9c-4f4b-9f8e-6b85f6ec388f	dF22XlqnTWygxZxOUuiTNR:APA91bE8Ot8iNf8gY_SGxfGLT0hHe1R1bTpZ8uuewkzG2VXAXuwYyULzC9myB2RV9VGdaj91EWV4QAFf8h5hXQuwz9XGeckDa8G1k-1t_dCjd9npXdry25w	android	2026-08-14 08:01:18.466613+00	2026-08-14 08:05:58.52418+00
\.


--
-- Data for Name: exams; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exams (id, teacher_id, course_id, title, duration_minutes, start_at, end_at, max_score, is_published, created_at, max_attempts, lesson_id) FROM stdin;
ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	4d817052-c05d-4927-a54b-7bbd5a128909	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اختبار علي المصادر السماعية والقياسية	30	2026-08-12 18:00:17.201342+00	2026-08-19 18:00:17.201345+00	12	t	2026-08-12 15:02:19.296029+00	3	aa8be204-c7d0-4b1a-afc3-6c0bc8431dd7
\.


--
-- Data for Name: exam_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exam_submissions (id, exam_id, student_id, score, total_points, started_at, submitted_at, answers) FROM stdin;
\.


--
-- Data for Name: lesson_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lesson_documents (id, lesson_id, title, file_url, file_type, created_at) FROM stdin;
\.


--
-- Data for Name: lesson_progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lesson_progress (id, student_id, lesson_id, is_completed, watched_seconds, last_watched_at, view_count) FROM stdin;
8c2f061c-3775-4574-8568-962caabfa6b3	e16b180a-0e82-4cd4-97b2-57eadb181b4a	9a641534-3a1c-4004-a16b-e9b8a1f4d180	f	0	2026-08-13 03:12:30.246438+00	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, title, body, category, is_read, created_at) FROM stdin;
12613a82-a27a-45a3-8db2-4abb3ab8c155	4d817052-c05d-4927-a54b-7bbd5a128909	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	f	2026-08-11 03:14:23.88925+00
848aa770-8dec-4005-a567-5be166fe046b	16128ef2-796d-47e9-a07e-87a5564eef99	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	f	2026-08-13 00:49:49.939857+00
827455ef-e65a-4673-90c0-05e31b30a194	2bb7a3ea-da47-4d47-ac23-e35326458c87	تم تفعيل اشتراكك	تم تفعيل اشتراكك بنجاح، يمكنك الآن متابعة جميع الدروس.	system	f	2026-08-13 00:52:22.961484+00
d5b23d5e-f063-4442-9bb8-ab03dc46e361	e16b180a-0e82-4cd4-97b2-57eadb181b4a	تم تفعيل اشتراكك	تم تفعيل اشتراكك بنجاح، يمكنك الآن متابعة جميع الدروس.	system	f	2026-08-13 03:12:16.639843+00
65da7341-5e27-48a9-80ad-0352a995c75d	76bdcafc-7873-4f66-8ffc-caa17bafadc3	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	t	2026-08-13 16:13:22.408846+00
22e2da55-9d6b-4474-80c3-14fe87cc9f48	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - المصدر الميمي والمصدر الصناعي	lesson	f	2026-08-14 23:56:37.738515+00
d5989f1c-752b-4f5b-aa44-03d7c09281b4	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - اسما الزمان والمكان	lesson	f	2026-08-15 17:14:32.966115+00
ce1d09f5-bc85-46cb-8153-bdb75c96e473	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - تدريبات على اسمي الزمان والمكان	lesson	f	2026-08-15 17:17:32.798584+00
888e8b82-7503-4b28-911d-ed79fd66fefe	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - المصدر المؤول وكيفية إعرابه	lesson	f	2026-08-15 18:59:14.281666+00
ad1028c0-67c8-47f5-bf83-1326914d1550	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - الاسم المقصور تثنيته وجمعه جمعا سالما	lesson	f	2026-08-15 19:04:00.346375+00
467c48fb-7aee-4fb6-bbba-0991f73caf7f	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - الاسم المنقوص تثنيته وجمعه جمعا سالما	lesson	f	2026-08-15 19:06:49.205102+00
089cf4c1-43cf-4e11-8c99-b799e2a144c7	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - تطبيقات عامة علي الوحدة الثانية رقم ١	lesson	f	2026-08-15 19:12:01.732015+00
6065417d-15c6-4084-a713-23c949fc4bf4	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - تدريبات علي المصدر الميمي والصناعي	lesson	f	2026-08-15 19:13:39.499543+00
aab874ca-2ce0-4938-b6eb-cfa7b55700b8	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - تطبيقات على الوحدة الثانية رقم ٢	lesson	f	2026-08-15 19:18:35.702368+00
9e903f11-554d-4c95-82fd-ad7cee4884b2	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي - الاسم الممدود تثنيته وجمعه جمعا سالما	lesson	f	2026-08-15 19:20:44.470815+00
ef45efe1-99e2-42ca-842f-40feb2980644	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	منهج القواعد النحوية للصف الأول الثانوي بكالوريا - تدريبات مراجعة نحوية مهمة علي ما سبق دراسته	lesson	f	2026-08-16 19:26:30.758195+00
4e7bea43-85fb-41e6-a808-08bf705b10bb	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	منهج القواعد النحوية للصف الأول الثانوي بكالوريا - شرح الأفعال الناسخة( كان وأخواتها )	lesson	f	2026-08-16 19:35:14.231097+00
2374c7ff-9c3c-44e2-b0d3-abd537e19090	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	منهج القواعد النحوية للصف الأول الثانوي بكالوريا - تدريبات مهمة ومتميزة علي كان وأخواتها	lesson	f	2026-08-16 19:37:21.529983+00
967dcb3b-628d-47d2-9e1b-a4911c42cee5	e16b180a-0e82-4cd4-97b2-57eadb181b4a	درس جديد	منهج القواعد النحوية للصف الأول الثانوي بكالوريا - الأفعال الناقصة والتامة المحاضرة الثانية	lesson	f	2026-08-16 19:41:17.829703+00
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_methods (id, student_id, card_holder, card_last4, card_brand, expiry_month, expiry_year, is_default, created_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payer_id, payer_type, plan_id, amount, payment_gateway, gateway_transaction_id, status, created_at, course_id) FROM stdin;
09d25b12-0a40-4e8f-b6da-18fb662d1909	2bb7a3ea-da47-4d47-ac23-e35326458c87	student_subscription	\N	0.00	fawry	CODE-TH-LNMC-UQJG	success	2026-08-13 00:52:23.068297+00	\N
7d38d4cb-8291-42a1-8b1a-84726faff82f	e16b180a-0e82-4cd4-97b2-57eadb181b4a	student_subscription	\N	0.00	fawry	CODE-TH-QCKQ-DEJX	success	2026-08-13 03:12:16.764394+00	\N
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questions (id, exam_id, question_type, text, options, correct_answer, points, "order", created_at) FROM stdin;
dfeed1a8-1cc1-4914-aab2-a22668ffe7c4	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	تسعي مصر لإيجاد الحلول من أجل تسوية النزاع وكشف ادعاءات اليهود\nالمصدر الخماسي في العبارة ووزنه	["إيجاد( إفعال)", "تسوية( تفعلة)", "النزاع( الفعال)", "ادعاءات ( افتعالات)"]	د	2	0	2026-08-12 15:07:08.510013+00
cacc9ba4-a766-4976-8ec3-90e31e62e849	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	حدد العبارة التي تضمنت مصدرا سداسيا	["استواء الطرق مفيد في تقليل الحوادث", "استياء الفريق من أنانية الفرد طبيعي", "استيلاء اليهود علي غزة جريمة وعار", "استباق الأحداث وسوء الظن يدمر العلاقة"]	ج	2	0	2026-08-12 15:10:42.456693+00
d2b3f65d-24af-4c3e-b78a-dd37305d34a8	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	الحكيم يتولي المسئولية ٠٠٠٠٠رشيدا ويدير أعماله بغير ٠٠٠٠٠٠٠\nضع مكان النقط مصدر الفعلين( تولي) ( تواني) علي الترتيب	["تول _ تواني", "تولية _ تواني", "توليا _ توان", "تولي _ توان"]	ج	2	0	2026-08-12 15:15:14.126539+00
6683e060-6eab-4021-aa9b-5c3e10d67405	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	استلال الأحقاد وإيلاف القلوب يكون بالتودد والحوار \nبين المصدر ونوعه في المقولة السابقة	["الحوار _ ثلاثي", "استلال _ سداسي", "التودد _ رباعي", "إيلاف _ رباعي"]	د	2	0	2026-08-12 15:17:46.611513+00
1a10e9b2-46d9-40a3-b48e-cbb61ee9e195	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	لا تسترقوا السمع ولا تسترقوا الناس وقد خلقوا أحرارا \nمصدر الفعلين( تسترقوا ) ( تسترقوا ) علي الترتيب	["استرقاق _ استراق", "استراق _ استرقاق", "إسراق _ تسارق", "استراق _ تسريق"]	ب	2	0	2026-08-12 15:22:32.104009+00
9faab955-91be-4ab9-b83d-114aa2c9235d	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	essay	هيأني الكتاب للامتحان فتهيأت \nاكتب مصدر الفعلين( هيأني ) والفعل( تهيأت ) علي الترتيب	[]	\N	2	0	2026-08-12 15:27:43.84554+00
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscriptions (id, student_id, teacher_id, status, starts_at, expires_at, created_at, activation_code_id) FROM stdin;
db13827f-b62f-41f0-943d-0019d677cec5	e16b180a-0e82-4cd4-97b2-57eadb181b4a	4d817052-c05d-4927-a54b-7bbd5a128909	active	2026-08-13 03:12:16.639843+00	2027-08-13 03:12:16.639843+00	2026-08-13 03:12:16.639843+00	4fd0d827-4954-486d-a22a-35ca69e315c0
\.


--
-- PostgreSQL database dump complete
--

\unrestrict fhLcuwboOeQbnIyDCUGI70g9K23plFVIv5cIHW5kSPgeviO7stdkfgMWEX0r9g8

