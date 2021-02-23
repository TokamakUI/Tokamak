// MIT License
//
// Copyright (c) 2019 Sergej Jaskiewicz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//  Created by Sergej Jaskiewicz on 31.10.2019.
//

#ifndef OPENCOMBINE_STRING_VIEW_H
#define OPENCOMBINE_STRING_VIEW_H

#include <iterator>
#include <cstddef>
#include <cstring>

namespace tokamak
{

  // This is a very simplified implementation of std::string_view from C++17.
  // Not all compilers support it yet.
  struct string_view
  {
    using traits_type = void;
    using value_type = char;
    using pointer = char *;
    using const_pointer = const char *;
    using reference = char &;
    using const_reference = const char &;
    using const_iterator = const char *;
    using iterator = const_iterator;
    using const_reverse_iterator = std::reverse_iterator<const_iterator>;
    using reverse_iterator = const_reverse_iterator;
    using size_type = size_t;
    using difference_type = std::ptrdiff_t;

    string_view() noexcept : string_view(nullptr, 0) {}
    string_view(const string_view &other) noexcept = default;
    string_view(const char *data, size_type size) : data_(data), size_(size) {}
    string_view(const char *data) : string_view(data, strlen(data)) {}

    string_view &operator=(const string_view &view) noexcept = default;

    const_pointer data() const noexcept { return data_; }

    constexpr size_type size() const noexcept { return size_; }

    const_iterator begin() const noexcept { return data_; }
    iterator begin() noexcept { return data_; }

    const_iterator end() const noexcept { return data_ + size_; }
    iterator end() noexcept { return data_ + size_; }

  private:
    const_pointer data_;
    size_type size_;
  };

} // end namespace tokamak

#endif /* OPENCOMBINE_STRING_VIEW_H */
