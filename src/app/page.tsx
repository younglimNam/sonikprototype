export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Hero Section - 더 화려한 그라디언트 배경 */}
      <section className="h-screen flex items-center justify-center bg-gradient-to-br from-indigo-900 via-purple-800 to-pink-800 text-white relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-20"></div>
        <div className="container mx-auto px-4 text-center relative z-10">
          <div className="bg-clip-text text-transparent bg-gradient-to-r from-teal-400 to-blue-500">
            <h1 className="text-6xl font-bold mb-4">안녕하세요!</h1>
          </div>
          <h2 className="text-3xl mb-6 text-teal-200">웹 개발자 포트폴리오입니다</h2>
          <p className="text-xl text-blue-200">Frontend Developer</p>
        </div>
      </section>

      {/* About Section - 부드러운 그라디언트 배경 */}
      <section className="py-20 bg-gradient-to-b from-slate-50 to-white">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-12 bg-clip-text text-transparent bg-gradient-to-r from-purple-600 to-pink-600">About Me</h2>
          <div className="max-w-3xl mx-auto">
            <p className="text-lg text-gray-700 mb-6 leading-relaxed">
              저는 사용자 경험을 중요시하는 프론트엔드 개발자입니다.
              새로운 기술을 배우는 것을 좋아하며, 깔끔하고 효율적인 코드 작성을 지향합니다.
            </p>
          </div>
        </div>
      </section>

      {/* Skills Section - 현대적인 디자인 */}
      <section className="py-20 bg-gradient-to-br from-slate-100 via-blue-50 to-purple-50">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-12 bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-teal-600">Skills</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8 max-w-3xl mx-auto">
            <div className="p-6 bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300 border border-blue-50">
              <h3 className="font-bold mb-4 text-xl text-blue-700">Frontend</h3>
              <ul className="text-gray-600 space-y-2">
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                  React
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                  Next.js
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                  TypeScript
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                  Tailwind CSS
                </li>
              </ul>
            </div>
            <div className="p-6 bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300 border border-purple-50">
              <h3 className="font-bold mb-4 text-xl text-purple-700">Backend</h3>
              <ul className="text-gray-600 space-y-2">
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                  Node.js
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                  Express
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                  MongoDB
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                  SQL
                </li>
              </ul>
            </div>
            <div className="p-6 bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300 border border-teal-50">
              <h3 className="font-bold mb-4 text-xl text-teal-700">Tools</h3>
              <ul className="text-gray-600 space-y-2">
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-teal-400 rounded-full"></span>
                  Git
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-teal-400 rounded-full"></span>
                  VS Code
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-teal-400 rounded-full"></span>
                  Figma
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-2 h-2 bg-teal-400 rounded-full"></span>
                  Postman
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Projects Section - 세련된 카드 디자인 */}
      <section className="py-20 bg-gradient-to-b from-white to-slate-50">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-12 bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 to-purple-600">Projects</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-5xl mx-auto">
            <div className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300 border border-indigo-50">
              <div className="h-48 bg-gradient-to-r from-indigo-500 to-purple-500 relative">
                {/* Project image will go here */}
              </div>
              <div className="p-6">
                <h3 className="font-bold text-xl mb-2 text-indigo-700">프로젝트 1</h3>
                <p className="text-gray-600 mb-4">
                  프로젝트에 대한 간단한 설명이 들어갑니다.
                </p>
                <div className="flex gap-2">
                  <span className="px-3 py-1 bg-gradient-to-r from-indigo-100 to-indigo-200 rounded-full text-sm text-indigo-700">React</span>
                  <span className="px-3 py-1 bg-gradient-to-r from-purple-100 to-purple-200 rounded-full text-sm text-purple-700">Next.js</span>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300 border border-purple-50">
              <div className="h-48 bg-gradient-to-r from-purple-500 to-pink-500 relative">
                {/* Project image will go here */}
              </div>
              <div className="p-6">
                <h3 className="font-bold text-xl mb-2 text-purple-700">프로젝트 2</h3>
                <p className="text-gray-600 mb-4">
                  프로젝트에 대한 간단한 설명이 들어갑니다.
                </p>
                <div className="flex gap-2">
                  <span className="px-3 py-1 bg-gradient-to-r from-purple-100 to-purple-200 rounded-full text-sm text-purple-700">TypeScript</span>
                  <span className="px-3 py-1 bg-gradient-to-r from-pink-100 to-pink-200 rounded-full text-sm text-pink-700">Node.js</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Section - 현대적인 그라디언트 */}
      <section className="py-20 bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900 text-white relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-20"></div>
        <div className="container mx-auto px-4 relative z-10">
          <h2 className="text-4xl font-bold text-center mb-12 bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-400">Contact</h2>
          <div className="max-w-xl mx-auto text-center">
            <p className="mb-8 text-blue-200">
              함께 일하고 싶으시다면 연락해주세요!
            </p>
            <div className="flex justify-center gap-6">
              <a href="mailto:your.email@example.com" className="px-6 py-3 bg-white bg-opacity-10 rounded-lg hover:bg-opacity-20 transition-colors duration-300">
                Email
              </a>
              <a href="https://github.com/yourusername" target="_blank" rel="noopener noreferrer" className="px-6 py-3 bg-white bg-opacity-10 rounded-lg hover:bg-opacity-20 transition-colors duration-300">
                GitHub
              </a>
              <a href="https://linkedin.com/in/yourusername" target="_blank" rel="noopener noreferrer" className="px-6 py-3 bg-white bg-opacity-10 rounded-lg hover:bg-opacity-20 transition-colors duration-300">
                LinkedIn
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
