
--Kategoriler Tablosu (Categories)
CREATE TABLE Categories (
    category_id SMALLINT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Üyeler Tablosu (Members)
CREATE TABLE Members (
    member_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    profile_level INTEGER DEFAULT 1,
    profile_points INTEGER DEFAULT 0
);

--Eğitimler Tablosu (Courses)
CREATE TABLE Courses (
    course_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    course_name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    category_id SMALLINT NOT NULL,
    max_participants INTEGER DEFAULT 100,
    price DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_course_category 
        FOREIGN KEY (category_id) 
        REFERENCES Categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_course_dates 
        CHECK (end_date >= start_date)
);

--Katılımlar Tablosu (Enrollments)
CREATE TABLE Enrollments (
    enrollment_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    member_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_status VARCHAR(20) DEFAULT 'enrolled',
    completion_date TIMESTAMP NULL,
    progress_percentage INTEGER DEFAULT 0,
    
    CONSTRAINT fk_enrollment_member 
        FOREIGN KEY (member_id) 
        REFERENCES Members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_enrollment_course 
        FOREIGN KEY (course_id) 
        REFERENCES Courses(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT uk_member_course 
        UNIQUE (member_id, course_id),
    
    CONSTRAINT chk_progress 
        CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    CONSTRAINT chk_completion_status 
        CHECK (completion_status IN ('enrolled', 'in_progress', 'completed', 'dropped'))
);

--Sertifikalar Tablosu (Certificates)
CREATE TABLE Certificates (
    certificate_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    certificate_code VARCHAR(100) NOT NULL UNIQUE,
    certificate_name VARCHAR(200) NOT NULL,
    issue_date DATE NOT NULL,
    template_path VARCHAR(500),
    validity_period_months INTEGER DEFAULT 12,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Sertifika Atamaları Tablosu (CertificateAssignments)
CREATE TABLE CertificateAssignments (
    assignment_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    member_id BIGINT NOT NULL,
    certificate_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    assignment_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE,
    is_valid BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT fk_assignment_member 
        FOREIGN KEY (member_id) 
        REFERENCES Members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_assignment_certificate 
        FOREIGN KEY (certificate_id) 
        REFERENCES Certificates(certificate_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_assignment_course 
        FOREIGN KEY (course_id) 
        REFERENCES Courses(course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT uk_member_certificate_course 
        UNIQUE (member_id, certificate_id, course_id)
);

-- 7. Blog Gönderileri Tablosu (BlogPosts)
CREATE TABLE BlogPosts (
    post_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id BIGINT NOT NULL,
    publish_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    tags VARCHAR(500),
    
    CONSTRAINT fk_blog_author 
        FOREIGN KEY (author_id) 
        REFERENCES Members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- İndeksler oluşturma (performans için)
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_members_username ON Members(username);
CREATE INDEX idx_courses_category ON Courses(category_id);
CREATE INDEX idx_courses_dates ON Courses(start_date, end_date);
CREATE INDEX idx_enrollments_member ON Enrollments(member_id);
CREATE INDEX idx_enrollments_course ON Enrollments(course_id);
CREATE INDEX idx_enrollments_status ON Enrollments(completion_status);
CREATE INDEX idx_certificates_code ON Certificates(certificate_code);
CREATE INDEX idx_blog_author ON BlogPosts(author_id);
CREATE INDEX idx_blog_publish_date ON BlogPosts(publish_date);
-- indexing biraz rastgele oldu çünkü gerçek hayatta en çok kullanılan seneryoları analiz etmek gerek
-- bu sayede en az kaynak kullanan en verimli index yaklaşımı elde edilebilir.

-- Trigger fonk. blog yazısı yayınlandığında üye puanını artırır.
CREATE OR REPLACE FUNCTION update_member_points()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_published = TRUE AND (OLD.is_published IS NULL OR OLD.is_published = FALSE) THEN
        UPDATE Members 
        SET profile_points = profile_points + 10
        WHERE member_id = NEW.author_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_blog_points
    AFTER UPDATE ON BlogPosts
    FOR EACH ROW
    EXECUTE FUNCTION update_member_points();

--Üye istatistikleri
CREATE VIEW MemberStats AS
SELECT 
    m.member_id,
    m.username,
    m.first_name,
    m.last_name,
    COUNT(DISTINCT e.course_id) as enrolled_courses,
    COUNT(DISTINCT ca.certificate_id) as earned_certificates,
    COUNT(DISTINCT bp.post_id) as blog_posts,
    m.profile_points,
    m.profile_level
FROM Members m
LEFT JOIN Enrollments e ON m.member_id = e.member_id
LEFT JOIN CertificateAssignments ca ON m.member_id = ca.member_id
LEFT JOIN BlogPosts bp ON m.member_id = bp.author_id
GROUP BY m.member_id, m.username, m.first_name, m.last_name, m.profile_points, m.profile_level;

--Kurs detayları
CREATE VIEW CourseDetails AS
SELECT 
    c.course_id,
    c.course_name,
    c.description,
    c.instructor_name,
    cat.category_name,
    c.start_date,
    c.end_date,
    COUNT(e.enrollment_id) as total_enrollments,
    COUNT(CASE WHEN e.completion_status = 'completed' THEN 1 END) as completed_count
FROM Courses c
LEFT JOIN Categories cat ON c.category_id = cat.category_id
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.description, c.instructor_name, 
         cat.category_name, c.start_date, c.end_date;

--View, bir veya birden fazla tablodan veri alan ve sonucu sanki bir tablo gibi gösteren sanal tablodur.
--Fiziksel olarak veri saklamaz, sadece bir SQL sorgusu tanımlar.

